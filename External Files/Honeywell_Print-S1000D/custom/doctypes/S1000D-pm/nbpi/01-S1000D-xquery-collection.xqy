xquery version "1.0";

(: Use XQuery to scall all of the XML fragment files in the S1000D zip
   and gather all "commonRepository" and "crossRefTable" items into a single file :)

<xquery>

<query type="warningRepository">
{

	(: ************************************ :)
	(: 1. "commonRepository" queries :)
	(: ************************************ :)

	for $doc in collection('S1000D-collection.xml')
	return ($doc/dmodule/content/commonRepository/warningRepository[1])

}
</query>

<query type="cautionRepository">
{
	for $doc in collection('S1000D-collection.xml')
	return ($doc/dmodule/content/commonRepository/cautionRepository[1])
}
</query>

<query type="partRepository">
{
	for $doc in collection('S1000D-collection.xml')
	return ($doc/dmodule/content/commonRepository/partRepository[1])
}
</query>

<query type="enterpriseRepository">
{
	for $doc in collection('S1000D-collection.xml')
	return ($doc/dmodule/content/commonRepository/enterpriseRepository[1])
}
</query>

<query type="supplyRepository">
{
	for $doc in collection('S1000D-collection.xml')
	return ($doc/dmodule/content/commonRepository/supplyRepository[1])
}
</query>

<query type="toolRepository">
{
	for $doc in collection('S1000D-collection.xml')
	return ($doc/dmodule/content/commonRepository/toolRepository[1])
}
</query>




<query type="productCrossRefTable">
{

	(: ************************************ :)
	(: 2. "crossRefTable" queries :)
	(: ************************************ :)

	(: PCT :)
	
	for $doc in collection('S1000D-collection.xml')
	return ($doc/dmodule/content/productCrossRefTable[1])
}
</query>


<query type="condCrossRefTable">
{

	(: CCT :)

	for $doc in collection('S1000D-collection.xml')
	return ($doc/dmodule/content/condCrossRefTable[1])
}
</query>

<query type="applicCrossRefTable">
{

	(: ACT :)

	for $doc in collection('S1000D-collection.xml')
	return ($doc/dmodule/content/applicCrossRefTable[not(child::applicCrossRefTableCatalog[1])])
}
</query>

<query type="applicCrossRefTableCatalog">
{

	(: ACT catalog :)

	for $doc in collection('S1000D-collection.xml')
	return ($doc/dmodule/content/applicCrossRefTable/applicCrossRefTableCatalog[1])
}
</query>

</xquery>