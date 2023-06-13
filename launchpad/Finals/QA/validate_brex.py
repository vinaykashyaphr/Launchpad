from sonovision.s1000d_helper import DataModule, get_working_directory
from lxml import etree as ET
from lxml.etree import XPath
from pathlib import Path
import re
import elementpath
# regexpNS = "http://exslt.org/regular-expressions"

s1000d_specs = {
    "S1000D_3-0-1": {
        "id": "id",
        "obj_path": "objpath",
        "allowed_obj": "objappl",
        "use": "objuse",
        "obj_value": "objval",
        "val": "val1",
        "val_form": "valtype",
        'context_rules': "content/brex/contextrules",
        "obj_rule": "structrules/objrule"
    },

    "S1000D_4-1": {
        "id": "id",
        "obj_path": "objectPath",
        "allowed_obj": "allowedObjectFlag",
        "use": "objectUse",
        "obj_value": "objectValue",
        "val": "valueAllowed",
        "val_form": "valueForm",
        'context_rules': "content/brex/contextRules",
        "obj_rule": "structureObjectRuleGroup/structureObjectRule"
    }
}

class BrexContextRule():
    def __init__(self, rule, spec):
        self.id = rule.attrib.get(spec['id'], None)
        obj_path = rule.find(spec['obj_path'])
        self.allowed_object_flag = obj_path.attrib.get(spec['allowed_obj'], "2")

        try:
            self.use = "".join(rule.find(spec['use']).itertext())
            self.use = re.sub(r'&gt;', r'>', self.use)
            self.use = re.sub(r'&lt;', r'<', self.use)
        except AttributeError:
            self.use = ""
        self.path_text = re.sub(r'(match|test)\(', r're:\1(', obj_path.text)
        self.path_text = re.sub(r'&gt;', r'>', self.path_text)
        self.path_text = re.sub(r'&lt;', r'<', self.path_text)
        # self.path = XPath(obj_path.text)
        self.value_allowed = {ov.get(spec["val"]) : ov.get(spec["val_form"], "single") for ov in rule.findall(spec["obj_value"]) if ov.get(spec["val"]) is not None}

    def validate_rule(self, xml):
        # nsmap = xml.nsmap
        # nsmap['re'] = regexpNS
        # print(xml.nsmap)
        # result = self.path(xml)
        try:
            result = xml.xpath(self.path_text, namespaces=xml.nsmap)
        except ET.XPathEvalError:
            try:
                # result = xml.xpath(self.path_text, namespaces=nsmap)
                result = elementpath.select(xml, self.path_text, namespaces=xml.nsmap)
            except elementpath.ElementPathError as e:
                print(f"ElementPath Error: {e} ({self.path_text})")
                return ""
        if (self.allowed_object_flag == "0" and result) or \
            (self.allowed_object_flag == "1" and not result):
                # print(ET.tostring(result[0]).decode(encoding='utf-8'))
                # print(self.use)
                return self.use + "\n"
        return ""

class BrexContextRuleGroup():
    def __init__(self, rules_xml, spec):
        self.schema = rules_xml.attrib.get('rulesContext', 'ALL').split('/')[-1]
        self._rules = BrexContextRuleGroup.get_rules(rules_xml, spec)
        # print(f"Context Rule Group for {self.schema} contains {len(self._rules)} rules")

    @staticmethod
    def get_rules(rule_group, spec):
        # return list(map(BrexContextRule, rule_group.findall(spec["obj_rule"])))
        return [BrexContextRule(rule, spec) for rule in rule_group.findall(spec["obj_rule"])]        

    def validate_rules(self, xml):
        output = ""
        for rule in self._rules:
            output += rule.validate_rule(xml)
        return output

class Brex():
    def __init__(self, filename):
        d = DataModule(filename)
        d.parse()
        root = d.root
        spec = re.search("S1000D[^/]+", root.attrib['{%s}noNamespaceSchemaLocation' % root.nsmap["xsi"]])
        spec = spec.group(0) if spec is not None else "S1000D_4-1"
        spec_dict = s1000d_specs.get(spec, s1000d_specs["S1000D_4-1"])

        self._context_rules = Brex.parse_context_rules(root.findall(spec_dict['context_rules']), spec_dict)

    @staticmethod
    def parse_context_rules(context_rules, spec):
        if not context_rules:
            raise RuntimeWarning("No context rules found!")

        return [BrexContextRuleGroup(rg, spec) for rg in context_rules]

    def validate(self, filename):
        d = DataModule(filename)
        d.parse()
        root = d.root
        schema = root.attrib['{%s}noNamespaceSchemaLocation' % root.nsmap["xsi"]].split('/')[-1]
        # print(f"Schema of {filename.name} is {schema}")
        output = ""
        for cr in self._context_rules:
            if cr.schema in {'ALL', schema}:
                output += cr.validate_rules(root)
        return output

if __name__ == "__main__":
    working_directory = get_working_directory()
    brexes = working_directory.glob("*MC*022A*.xml")
    # brex = Brex(input("Input Brex Filename"))
    
    for brex in brexes:
        errors = False
        print(f"Validating against {brex.name}")
        brex = Brex(brex)
        for module in working_directory.glob("*MC*.xml"):
            result = brex.validate(module)
            errors = errors or bool(result)
            print(f"Validate {module.name}")
            if result:
                print(result)
        if not errors:
            print("     Success! No errors detected.\n")
    print("Validation Completed!")
