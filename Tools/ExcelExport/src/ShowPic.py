# -*- coding:utf8 -*-
# from PIL import Image

# img = Image.open('image.png')

# -----------------------------------------------------
# ascii_img = img.convert('L').resize((160, 180))
# ascii_img.show()

# -----------------------------------------------------
# ascii_chars = [' ', '.', ':', '-', '+', '*', '?', '%', 'S', '#', '@']
# ascii_img = img.convert('L').resize((160, 180))
# ascii_str = ''

# for y in range(ascii_img.size[1]):
#     for x in range(ascii_img.size[0]):
#         pixel = 255 - ascii_img.getpixel((x, y))
#         index = int(pixel / 25)
#         ascii_str += ascii_chars[index]
#     ascii_str += '\n'

# print(ascii_str)

# -----------------------------------------------------
from PIL import Image
import random

class ShowPic:
	def showyy(self):
		CHARS = [' ', '.', ':', '-', '=', '+', '*', '#', '%', '@', 'W', 'M', 'B', '$', '&', '8']
		# CHARS = [' ', '.', ':', '*', '*', '+', '*', '#', '#', '#', '#', '#', '#', '#', '#', ' ']

		who = random.randint(1,3)
		img = Image.open('../export/image%d.png'%who)

		width, height = img.size
		aspect_ratio = height / width
		new_width = 80
		new_height = int(aspect_ratio * new_width * 0.55)
		img = img.resize((new_width, new_height))

		img = img.convert('L')

		pixels = img.getdata()
		chars = [CHARS[int(pixel / 16)] for pixel in pixels]
		chars = ''.join(chars)

		for i in range(0, len(chars), new_width):
		    print(chars[i:i+new_width])
    
#     
#------------------------------------------------------

# from PIL import Image

# img = Image.open('image.png')

# CHARS = [' ', '.', ':', '-', '=', '+', '*', '#', '%', '@', 'W', 'M', 'B', '$', '&', '8']

# def get_char(pixel):
#     """
#     根据像素值获取对应的字符
#     """
#     return CHARS[int(pixel / 16)]

# def replace_area(chars, x, y, width, height, replace_char):
#     """
#     将指定区域用指定字符代替
#     """
#     for i in range(y, y+height):
#         for j in range(x, x+width):
#             index = i * new_width + j
#             chars[index] = replace_char

# def replace_area_by_color(chars, color, replace_char):
#     """
#     根据颜色值将指定区域用指定字符代替
#     """
#     for i in range(new_height):
#         for j in range(new_width):
#             index = i * new_width + j
#             pixel = img.getpixel((j, i))
#             if pixel == color:
#                 chars[index] = replace_char

# # 调整图片大小
# width, height = img.size
# aspect_ratio = height / width
# new_width = 80
# new_height = int(aspect_ratio * new_width * 0.55)
# img = img.resize((new_width, new_height))

# # 转换为灰度图像
# img = img.convert('L')

# # 获取像素值并转换为字符
# pixels = img.getdata()
# chars = [get_char(pixel) for pixel in pixels]

# # 将人脸部分用空格代替
# replace_area_by_color(chars, (255, 200, 150), ' ')

# # 将除人脸以外的部分用#代替
# replace_area_by_color(chars, (0, 0, 0), '-')

# # 输出字符画
# for i in range(0, len(chars), new_width):
#     print(''.join(chars[i:i+new_width]))

