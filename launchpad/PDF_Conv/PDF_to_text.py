import pdfminer3
from pdfminer3.converter import PDFPageAggregator
from pdfminer3.layout import LAParams
from pdfminer3.pdfdocument import PDFDocument
from pdfminer3.pdfinterp import PDFResourceManager, PDFPageInterpreter
from pdfminer3.pdfpage import PDFPage, PDFTextExtractionNotAllowed
from pdfminer3.pdfparser import PDFParser
import time

try:
    from .Algorithms import sorting
except ImportError:
    from Algorithms import sorting

def extract_pdf_layout(file):
	"""
	Extracts LTPage objects from a pdf file.

	slightly modified from
	https://euske.github.io/pdfminer/programming.html
	"""

	laparams = LAParams()
	
	#fp = get_user_input_pdf(input_text)
	fp = open(str(file), 'rb')
	st = time.time()
	print('Please wait while data is being collected')

	parser = PDFParser(fp)
	
	document = PDFDocument(parser)

	if not document.is_extractable:
		raise PDFTextExtractionNotAllowed

	rsrcmgr = PDFResourceManager()
	device = PDFPageAggregator(rsrcmgr, laparams=laparams)
	interpreter = PDFPageInterpreter(rsrcmgr, device)

	line_obj = LineObjects()
	char_lines = LineChars()
	texts, curves, h_lines, v_lines, boxes, figures, pagesize = [], [], [], [], [], [], []
	for (n, page) in enumerate(PDFPage.create_pages(document)):
		print("Processing page: {}".format(n + 1), end='')
		interpreter.process_page(page)
		layouts = device.get_result()
		t, c, h, v, b, f, p = convert_pdf_data(layouts, char_lines, line_obj)
		texts.append(t)
		curves.append(c)
		h_lines.append(h)
		v_lines.append(v)
		boxes.append(b)
		figures.append(f)
		pagesize.append(p)
		print(end='\r')
	print("Done processing {} pages in {}sec".format(n + 1, round((time.time() - st), 3)))
	fp.close()
	return texts, curves, h_lines, v_lines, boxes, figures, pagesize


def get_user_input_pdf(input_text):
	while True:
		user_input = input(input_text)
		try:
			pdf_path = str(user_input).replace('\'', '').replace('"', '')
			pdf = pdf_path.split('\\')[-1]
			fp = open(pdf, 'rb')
			break
		except OSError as err:
			print('Error: {}'.format(err))
			continue
	return fp


def convert_pdf_data(pdf_data, char_lines, line_obj):
	chars, curves, figures = [], [], []
	pagesize = pdf_data.bbox
	for elements in pdf_data._objs:
		# collects text elements on the page
		if isinstance(elements, pdfminer3.layout.LTTextBoxHorizontal) or \
				isinstance(elements, pdfminer3.layout.LTTextBox):
			for elem in elements._objs:
				char_line = LineChars.text_data_simple(char_lines, elem)
				for char in char_line:
					chars.append(char)
		# collects line elements on the page, is useful for reading certain tables, future implementation
		elif isinstance(elements, pdfminer3.layout.LTLine) or \
				isinstance(elements, pdfminer3.layout.LTCurve):
			center = (round((elements.bbox[2] + elements.bbox[0]) / 2),
					  round((elements.bbox[3] + elements.bbox[1]) / 2))
			curves.append({'x0': int(elements.bbox[0]), 'y0': int(elements.bbox[1]),
						   'x1': int(elements.bbox[2]), 'y1': int(elements.bbox[3]),
						   'centerX': center[0], 'centerY': center[1]})
		elif isinstance(elements, pdfminer3.layout.LTFigure) \
				or isinstance(elements, pdfminer3.layout.LTImage):
			center = (round((elements.bbox[2] + elements.bbox[0]) / 2),
					  round((elements.bbox[3] + elements.bbox[1]) / 2))
			figures.append({'x0': int(elements.bbox[0]), 'y0': int(elements.bbox[1]),
							'x1': int(elements.bbox[2]), 'y1': int(elements.bbox[3]),
							'centerX': center[0], 'centerY': center[1], 'name': elements.name})

	h_lines, v_lines, other_boxes = LineObjects.create_lines(line_obj, curves)
	boxes = LineObjects.boxes(line_obj, h_lines, v_lines)
	return chars, curves, h_lines, v_lines, boxes, figures, pagesize


class LineChars(object):

	def __init__(self, margin=10):
		self.space_margin = margin
		self.dash_size = 8
		return

	def text_data_simple(self, data):
		"""
		returns a simple dictionary that contains the text data and location data,
		easier to use for data mining
		"""
		char_margin = 1
		bbox = data.bbox
		char = []
		prev_letter = data._objs[0]
		for (n, letter) in enumerate(data._objs):
			superscript, subscript = False, False
			if isinstance(letter, pdfminer3.layout.LTChar):
				if letter.bbox[1] > prev_letter.bbox[1] + char_margin and \
						letter.bbox[3] > prev_letter.bbox[3] + char_margin:
					superscript = True
				elif letter.bbox[1] < prev_letter.bbox[1] - char_margin and \
						letter.bbox[3] < prev_letter.bbox[3] - char_margin:
					subscript = True
				else:
					prev_letter = letter
				x1 = letter.bbox[2]
				try:
					if letter._text == ' ':
						nxt_char = data._objs[n + 1]
						if x1 > nxt_char.bbox[0]:
							x1 = nxt_char.bbox[0]
				except Exception:
					pass
				char.append({'x0': round(letter.bbox[0], 2), 'y0': round(bbox[1], 2),
							 'x1': round(x1, 2), 'y1': round(bbox[3], 2),
							 'char': letter._text, 'font': letter.fontname, 'color': letter.ncs,
							 'superscript': superscript, 'subscript': subscript, 'underline': False})
			if isinstance(letter, pdfminer3.layout.LTAnno):
				try:
					if letter._text == '\n':
						continue
					else:
						prv_obj, nxt_obj = data._objs[n - 1], data._objs[n + 1]
						if nxt_obj.bbox[0] - prv_obj.bbox[2] < self.space_margin:
							char.append({'x0': round(prv_obj.bbox[2], 2), 'y0': round(bbox[1], 2),
										 'x1': round(nxt_obj.bbox[0], 2), 'y1': round(bbox[3], 2),
										 'char': ' ', 'font': char[-1]['font'], 'color': char[-1]['color'],
										 'superscript': superscript, 'subscript': subscript, 'underline': False})
				except IndexError or KeyError:
					pass
		return char

	def create_text_lines(self, data, boxes):
		lines = []
		sorting(data, ('x0', 'y0'), (False, True))
		if boxes:
			for box in boxes:
				box_chars = []
				text_in_box = False
				n = 0
				while n + 1 < len(data):
					char = data[n]
					center = round((char['x0'] + char['x1']) / 2, 2), round((char['y0'] + char['y1']) / 2, 2)
					if box['x0'] < center[0] < box['x1'] and box['y0'] < center[1] < box['y1']:
						text_in_box = True
						box_chars.append(char)
						del data[n]
					else:
						n += 1

				if text_in_box:
					LineChars.char_test(self, box_chars, lines)
				else:
					x0, y0, x1, y1 = round(box['x0'], 2), round(box['y0'], 2), round(box['x1'], 2), round(box['y1'], 2)
					center = round((x0 + x1) / 2, 2), round((y0 + y1) / 2, 2)
					tab_char = [{'x0': x0, 'y0': y0, 'x1': x1, 'y1': y1, 'char': '\t', 'font': False, 'color': False,
								'superscript': False, 'subscript': False, 'underline': False}]
					lines.append({'x0': x0, 'y0': y0, 'x1': x1, 'y1': y1, 'centerX': center[0], 'centerY': center[1],
								  'text': '\t', 'char': tab_char})
		LineChars.char_test(self, data, lines)
		return lines

	def char_test(self, data, lines):
		n = 0
		x_margin = 1
		if len(data) == 1:
			char = data[0]
			center = (round((char['x1'] + char['x0']) / 2), round((char['y1'] + char['y0']) / 2))
			x0, y0, x1, y1 = round(char['x0'], 2), round(char['y0'], 2), round(char['x1'], 2), round(char['y1'], 2)
			lines.append({'x0': x0, 'y0': y0, 'x1': x1, 'y1': y1, 'centerX': center[0], 'centerY': center[1],
						  'text': char['char'], 'char': data})

		while n + 1 < len(data):
			char = data[n]

			# removing space at the beginning of a text line
			if char['char'] == ' ':
				del data[n]
				continue

			text = char['char']
			line_chars = [char]
			x0, y0, x1, y1 = char['x0'], char['y0'], char['x1'], char['y1']

			# constructing line if in a box
			while True:
				try:
					nxt_char = data[n + 1]
					nxt_x0, nxt_y0, nxt_x1, nxt_y1 = nxt_char['x0'], nxt_char['y0'], nxt_char['x1'], nxt_char['y1']
					if x0 - x_margin < nxt_x0 < x1 + x_margin and y0 == nxt_y0 and y1 == nxt_y1:
						if nxt_char['char'] == ' ' and nxt_char['x1'] - nxt_char['x0'] > self.space_margin:
							del data[n + 1]
							break
						text += nxt_char['char']
						line_chars.append(nxt_char)
						x1 = nxt_x1
						del data[n + 1]
					else:
						n += 1
						break
				except IndexError:
					break

			if line_chars[-1]['char'] == ' ':
				text = text[:-1]
				line_chars = line_chars[:-1]
			center = (round((x1 + x0) / 2), round((y1 + y0) / 2))
			x0, y0, x1, y1 = round(x0, 2), round(y0, 2), round(x1, 2), round(y1, 2)
			lines.append({'x0': x0, 'y0': y0, 'x1': x1, 'y1': y1, 'centerX': center[0], 'centerY': center[1],
						  'text': text, 'char': line_chars})
		return

	def create_dashes(self, chars, curves):
		potential_dashes = []
		for curve in curves:
			if curve['x1'] - curve['x0'] < self.dash_size:
				curve['centerX'] = round((curve['x1'] + curve['x0'])/2, 2)
				potential_dashes.append(curve)

		dashes = []
		for pot_dash in potential_dashes:
			add_dash = False
			for (n, char) in enumerate(chars):
				if char['x0'] < pot_dash['centerX'] < char['x1'] and char['y0'] < pot_dash['y'] < char['y1']:
					add_dash = False
					break
				elif char['y0'] < pot_dash['y'] < char['y1'] and char['x0'] < pot_dash['x0'] < char['x1']:
					add_dash = False
					try:
						if chars[n+1]['y0'] < pot_dash['y'] < chars[n+1]['y1'] and \
								chars[n+1]['x0'] < pot_dash['x1'] < chars[n+1]['x1']:
							dashes.append({'x0': char['x1'], 'y0': char['y0'], 'x1': chars[n+1]['x0'], 'y1': char['y1'],
										   'char': '-', 'font': char['font'], 'color': char['color'],
										   'superscript': False, 'subscript': False, 'underline': False})
						else:
							dashes.append({'x0': char['x1'], 'y0': char['y0'], 'x1': pot_dash['x1'], 'y1': char['y1'],
										   'char': '-', 'font': char['font'], 'color': char['color'],
										   'superscript': False, 'subscript': False, 'underline': False})
					except IndexError:
						dashes.append({'x0': char['x1'], 'y0': char['y0'], 'x1': pot_dash['x1'], 'y1': char['y1'],
									   'char': '-', 'font': char['font'], 'color': char['color'],
									   'superscript': False, 'subscript': False, 'underline': False})
						break

					break

				else:
					add_dash = True
			if add_dash:
				dashes.append({'x0': pot_dash['x0'], 'y0': pot_dash['y'] - 5, 'x1': pot_dash['x1'],
							   'y1': pot_dash['y'] + 5, 'char': '-', 'font': 'Arial', 'color': 'black',
							   'superscript': False, 'subscript': False, 'underline': False})
		for dash in dashes:
			chars.append(dash)
		return


class LineObjects(object):

	def __init__(self, margin=2):
		self.margin = margin
		return

	def boxes(self, h_line, v_line):
		boxes = []
		for n, h in enumerate(h_line[:-1]):
			for m, v in enumerate(v_line[:-1]):
				if h['x0'] - self.margin <= v['x'] <= h['x1'] + self.margin and \
						v['y0'] - self.margin <= h['y'] <= v['y1'] + self.margin:
					for h_next in h_line[n + 1:]:
						if h_next == h:
							continue
						if h_next['x0'] - self.margin <= v['x'] <= h_next['x1'] + self.margin and \
								v['y0'] - self.margin <= h_next['y'] <= v['y1'] + self.margin:
							for v_next in v_line[m + 1:]:
								if v_next == v:
									continue
								if h['x0'] - self.margin <= v_next['x'] <= h['x1'] + self.margin and \
										v_next['y0'] - self.margin <= h['y'] <= v_next['y1'] + self.margin and \
										v_next['y0'] - self.margin <= h_next['y'] <= v_next['y1'] + self.margin:
									boxes.append({'x0': v['x'], 'y0': h_next['y'], 'x1': v_next['x'], 'y1': h['y']})
									break
							break
		return boxes

	def create_lines(self, curves):
		all_lines = [dict(t) for t in {tuple(d.items()) for d in curves}]
		sorting(all_lines, ('x0', 'centerY'), (False, True))
		horizontal_lines = []
		vertical_lines = []
		boxes = []
		while all_lines:
			line_temp = []

			if all_lines[0]['y1'] - self.margin <= all_lines[0]['y0'] <= all_lines[0]['y1'] + self.margin:
				line_temp.append(all_lines[0])
				for line in all_lines:
					if line['y0'] - self.margin <= all_lines[0]['y0'] <= line['y0'] + self.margin and \
							line['y1'] - self.margin <= all_lines[0]['y1'] <= line['y1'] + self.margin and \
							line != all_lines[0]:
						line_temp.append(line)
				check_pos = all_lines[0]['centerY']
				sorting(line_temp, 'x0', False)
				all_lines.remove(line_temp[0])
				x0 = line_temp[0]['x0']
				x1 = line_temp[0]['x1']
				for (n, line) in enumerate(line_temp[1:]):
					if line['x0'] - self.margin <= line_temp[n]['x1'] <= line['x0'] + self.margin:
						x1 = line['x1']
						all_lines.remove(line)
					else:
						break
				horizontal_lines.append({'x0': x0, 'x1': x1, 'y': check_pos})

			elif all_lines[0]['x1'] - self.margin <= all_lines[0]['x0'] <= all_lines[0]['x1'] + self.margin:
				line_temp.append(all_lines[0])
				for line in all_lines:
					if line['x0'] - self.margin <= all_lines[0]['x0'] <= line['x0'] + self.margin and \
							line['x1'] - self.margin <= all_lines[0]['x1'] <= line['x1'] + self.margin and \
							line != all_lines[0]:
						line_temp.append(line)
				check_pos = all_lines[0]['centerX']
				sorting(line_temp, 'y1', False)
				all_lines.remove(line_temp[0])
				y0 = line_temp[0]['y0']
				y1 = line_temp[0]['y1']
				for (n, line) in enumerate(line_temp[1:]):
					if line['y0'] - self.margin <= line_temp[n]['y1'] <= line['y0'] + self.margin:
						y1 = line['y1']
						all_lines.remove(line)
					else:
						break
				vertical_lines.append({'y0': y0, 'y1': y1, 'x': check_pos})

			else:
				boxes.append(all_lines[0])
				all_lines.remove(all_lines[0])
				continue

		if horizontal_lines and vertical_lines:
			sorting(horizontal_lines, 'y', True)
			sorting(vertical_lines, 'x', False)

		return horizontal_lines, vertical_lines, boxes
