import time
import io
import os
import pickle

from pathlib import Path

try:
    from Organize import Crop, Remove_FigText, Underlined, TextMerge
    from Algorithms import sorting
    from PDF_to_text import extract_pdf_layout, LineChars
except ImportError:
    from launchpad.PDF_Conv.Organize import Crop, Remove_FigText, Underlined, TextMerge
    from launchpad.PDF_Conv.Algorithms import sorting
    from launchpad.PDF_Conv.PDF_to_text import extract_pdf_layout, LineChars

#Launchpad stuff
try:
	from flask_socketio import SocketIO
	from socketio import Client
	from threading import Event
except ImportError:
	pass

def main(file, directory, user):

	supernova = SuperNova()
	
	#If we've already converted this file, there should be a pickle file in the directory
	if (directory / "raw_data_pdf.pickle").is_file():
		file = directory / "raw_data_pdf.pickle"
		
	#if os.path.isfile('raw_data_pdf.pickle'):
	if file.suffix.lower() == ".pickle":
		#print("Found PDF .pickle file")
		with open(str(file), "rb") as fs:
			raw_data_pdf = pickle.load(fs)
		#debug(supernova) #TODO: Instead of debug, add advance options to form to pass to method
	else:
		raw_data_pdf = extract_pdf_layout(file)
		with open(str(directory / "raw_data_pdf.pickle"), "wb") as fs:
			pickle.dump(raw_data_pdf, fs)

	start_loop = time.time()
	print('Parsing PDF')
	text = SuperNova.parsing_loop(supernova, raw_data_pdf)
	print('Finished parsing PDF in {}sec'.format(round((time.time() - start_loop), 3)))

	write_to_file(text, directory)
	return


# def debug(class_mod):
	# if get_input_answer('Enter Debug Mode? (enter y or n): '):
		# if get_input_answer('Resize Cropping area? (enter y or n): '):
			# print('Default values top: {}, bottom: {}'.format(class_mod.crop.top, class_mod.crop.bottom))
			# class_mod.crop.top = get_input_int('Enter new top value (enter positive int): ')
			# class_mod.crop.bottom = get_input_int('Enter new bottom value (enter positive int): ')
			# print('Default page to start cropping: {}'.format(class_mod.start_page))
			# class_mod.start_page = get_input_int('Enter page to start cropping (enter positive int): ')
		# if get_input_answer('Adjust paragraph merging margin (enter y or n): '):
			# print('Default margin int: {}'.format(class_mod.text_merge.para_margin))
			# class_mod.text_merge.para_margin = get_input_float('Enter new para_margin (enter positive float): ')
	# return


# def get_input_answer(question):
	# while True:
		# user_input = input(question)
		# try:
			# answer = str(user_input).strip().lower()
			# if answer in 'yes' or 'yes' in answer:
				# return True
			# elif answer in 'no' or 'no' in answer:
				# return False
			# else:
				# print("Please enter y or n")
				# continue
		# except ValueError as err:
			# print('Error {}'.format(err))
			# continue


# def get_input_int(question):
	# while True:
		# user_input = input(question)
		# try:
			# answer = int(user_input)
			# if answer > 0:
				# return answer
			# else:
				# print('please enter a positive integer')
				# continue
		# except ValueError as err:
			# print('Error {}'.format(err))
			# continue


# def get_input_float(question):
	# while True:
		# user_input = input(question)
		# try:
			# answer = float(user_input)
			# if answer > 0:
				# return answer
			# else:
				# print('please enter a positive value')
				# continue
		# except ValueError as err:
			# print('Error {}'.format(err))
			# continue


def write_to_file(text, dir):
	file = io.open(str(dir / 'parsed_text.txt'), 'w', encoding='utf-8')
	for (m, page_lines) in enumerate(text):
		if page_lines:
			for line in page_lines:
				if line:
					# file.write(line['text'])
					prev_char = {'bbox': False, 'char': '', 'font': 'Arial', 'color': False,
								 'superscript': False, 'subscript': False, 'underline': False}
					for char in line['char']:
						test_char_questions(char, prev_char, file)
						file.write(char['char'])
						prev_char = char
					char = {'bbox': False, 'char': '', 'font': 'Arial', 'color': False,
							'superscript': False, 'subscript': False, 'underline': False}
					test_char_questions(char, prev_char, file)
				file.write('\n')
	return


def test_char_questions(char, prev_char, file):
	if char['font'] and prev_char['font']:
		if char['font'].lower() in 'bold' and not prev_char['font'].lower() in 'bold':
			file.write('<boldtext>')
		elif prev_char['font'].lower() in 'bold' and not char['font'].lower() in 'bold':
			file.write('</boldtext>')
	test_char(char, prev_char, 'superscript', file)
	test_char(char, prev_char, 'subscript', file)
	test_char(char, prev_char, 'underline', file)
	return


def test_char(c, p_c, key, file):
	if c[key] and not p_c[key]:
		file.write('<' + key + '>')
	elif p_c[key] and not c[key]:
		file.write('</' + key + '>')
	return


class SuperNova(object):

	def __init__(self, top=715, bottom=65, para_margin=1, underline_margin=2, start_page=1):
		self.flags = {'IPL': False}
		self.remove_fig_text = True
		self.crop = Crop(top=top, bottom=bottom)
		self.underline = Underlined(margin=underline_margin)
		self.text_merge = TextMerge(para_margin=para_margin)
		self.line_chars = LineChars()
		self.start_page = start_page
		return

	def parsing_loop(self, data):
		chars, curves, h_lines, v_lines, boxes, figures, page_size = data

		texts = []
		print(end='')
		for n, (ch, c, h, v, f, b, dim) in enumerate(zip(chars, curves, h_lines, v_lines, figures, boxes, page_size)):
			print(end='\r')
			print('Sorting data on page {}'.format(n + 1), end='')

			try:
				LineChars.create_dashes(self.line_chars, ch, h)
				texts.append(LineChars.create_text_lines(self.line_chars, ch, b))
				sorting(texts[n], ('x0', 'centerY'), (False, True))
				sorting(f, ('centerX', 'centerY'), (False, True))
				sorting(c, ('x0', 'centerY'), (False, True))
				if n >= self.start_page:
					Crop.crop_top_bottom(self.crop, texts[n], c, f, dim)
				if self.remove_fig_text and f:
					Remove_FigText(f, texts[n])
				Underlined.find_underlines(self.underline, c, texts[n])
			except IndexError or KeyError:
				continue

		for n, (t, c, f, dim) in enumerate(zip(texts, curves, figures, page_size)):
			print(end='\r')
			print('Formatting data on page: {}'.format(n + 1), end='')

			try:
				if t[0]['text'] == '4. Detailed Parts List' or t[1]['text'] == 'Detailed Parts List' or \
						t[0]['text'] == '4. Equipment Designator Index' or t[1]['text'] == 'Equipment Designator Index':
					self.flags['IPL'] = True
				if not self.flags['IPL']:
					TextMerge.para_merge(self.text_merge, t)
				TextMerge.line_merge(self.text_merge, t)
			except IndexError or KeyError:
				continue
		print(end='\r')
		return texts


if __name__ == "__main__":
	start = time.time()
	try:
		pdf_file = input("Enter PDF Name. Leave blank if a .pickle file exists: ")
		main(Path('.') / pdf_file, Path('.'), None)
		print("total time: {}sec".format(round((time.time() - start), 3)))
	except Exception as e:
		print('\nERROR')
		print(e.__doc__)
		print(str(e))
		raise
	input("\npress enter to exit")
