try:
    from .Algorithms import sorting
except ImportError:
    from Algorithms import sorting


class TextMerge(object):

    def __init__(self, margin=3, para_margin=1, x_margin=1, line_margin=2):
        self.margin = margin
        self.para_margin = para_margin
        self.line_margin = line_margin
        self.x_margin = x_margin
        self.bullets = ['•', '', 'NOTE:', 'NOTES:', 'WARNING:', 'CAUTION:']
        self.line_ends = ['-', '\\', '/', '_', ' ', '°']
        return

    def line_merge(self, data):
        """
        will merge lines that have the same y value
        """
        n = 0
        while n < len(data):
            temp_lines = [data[n]]
            y0 = data[n]['y0'] + self.line_margin
            y1 = data[n]['y1'] - self.line_margin
            for line in data[n + 1:]:
                if not (line['y1'] < y0 or line['y0'] > y1):
                    temp_lines.append(line)
                    if line['y1'] > y1:
                        y1 = line['y1'] - self.line_margin
                    if line['y0'] < y0:
                        y0 = line['y0'] + self.line_margin
            if len(temp_lines) > 1:
                sorting(temp_lines, 'centerX', False)
                for line in temp_lines[1:]:
                    TextMerge.merging(temp_lines[0], line)
                    try:
                        data.remove(line)
                    except ValueError:
                        pass
            n += 1

    @staticmethod
    def merging(text, merging_text):
        if not(text['char'][-1]['char'] == ' ' or merging_text['char'][0]['char'] == ' '):
            text['char'].append({'bbox': False, 'char': '\t', 'font': False, 'color': False,
                                 'superscript': False, 'subscript': False, 'underline': False})
            text['text'] += '\t' + merging_text['text']
        else:
            text['text'] += merging_text['text']
        for char in merging_text['char']:
            text['char'].append(char)
        return

    def para_merge(self, data):
        n = 0
        key_to_figure = False
        while n < len(data) - 1:
            line = data[n]
            temp_lines = [line]

            if key_to_figure:
                y0 = line['y0']
                n += 1
                next_y1 = data[n]['y1']
                if y0 - 10 > next_y1:
                    key_to_figure = False
                continue
            if "key to figure" in line['text'].strip().lower() or 'key for figure' in line['text'].strip().lower():
                key_to_figure = True

            for next_line in data[n + 1:]:
                # check if lines are close in the y direction to merge
                # and if lines over lap in the x direction to merge
                if (line['y0'] - next_line['y1']) < self.para_margin and \
                        not (line['x1'] < next_line['x0'] or line['x0'] > next_line['x1']) and \
                        not next_line['text'][0] in self.bullets:
                    temp_lines.append(next_line)
                    line = next_line
            if len(temp_lines) > 1:
                prev_l = temp_lines[0]
                for l in temp_lines[1:]:
                    if not(prev_l['char'][-1]['char'] in self.line_ends or l['char'][0]['char'] in self.line_ends):
                        data[n]['char'].append({'bbox': False, 'char': ' ', 'font': False, 'color': False,
                                                'superscript': False, 'subscript': False, 'underline': False})
                        data[n]['text'] += ' '
                    for char in l['char']:
                        data[n]['char'].append(char)
                    data[n]['text'] += l['text']
                    data[n]['y0'] = l['y0']
                    if data[n]['x0'] > l['x0']:
                        data[n]['x0'] = l['x0']
                    if data[n]['x1'] < l['x1']:
                        data[n]['x1'] = l['x1']
                    data.remove(l)
            n += 1
        return


class Crop(object):

    def __init__(self, top=715, bottom=65, left=10):
        self.top = top
        self.bottom = bottom
        self.left = left
        return

    def crop_top_bottom(self, data, fig, rect, dim):

        c_top_loc = dim[1] + self.top
        c_bot_loc = dim[1] + self.bottom

        n = 0
        while n < len(data):
            elem = data[n]
            if not c_bot_loc < elem['centerY'] < c_top_loc or not elem['x0'] > self.left:
                data.remove(elem)
            elif elem['text'] == '':
                data.remove(elem)
            else:
                n += 1

        n = 0
        while n < len(fig):
            elem = fig[n]
            if not c_bot_loc < elem['centerY'] < c_top_loc:
                fig.remove(elem)
            else:
                n += 1

        n = 0
        while n < len(rect):
            elem = rect[n]
            if not c_bot_loc < elem['centerY'] < c_top_loc:
                rect.remove(elem)
            else:
                n += 1
        return


class Underlined(object):

    def __init__(self, margin=2, horizontal=2):
        self.under_margin = margin
        self.hor_margin = horizontal
        return

    def find_underlines(self, curve, text):
        for c in curve:
            if abs(c['y0'] - c['y1']) < self.hor_margin:
                for line in text:
                    for char in line['char']:
                        if (char['y0'] - 1) < c['centerY'] < (char['y0'] + self.under_margin) and \
                                (char['x0'] + 1) > c['x0'] and (char['x1'] - 1) < c['x1']:
                            char['underline'] = True
        return


def Remove_FigText(figure, text):
    n = 0
    removed = False
    while n < len(text):
        line = text[n]
        for fig in figure:
            if text[n]['text'].startswith('Figure'):
                return
            elif (fig['x0'] <= line['centerX'] <= fig['x1']
                  and fig['y0'] <= line['centerY'] <= fig['y1']):
                text.remove(line)
                removed = True
                break
            else:
                removed = False
        if not removed:
            n += 1
    return
