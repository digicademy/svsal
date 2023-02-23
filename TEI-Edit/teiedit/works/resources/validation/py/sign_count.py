'''
Created on 19.06.2017

@author: David
'''

import sys
import io
import re

if len(sys.argv) != 2:
    print("Unzulässige Anzahl an Eingabe-Parametern: Eingabe muss genau 1 (relativer oder absoluter) Dateipfad sein.")

input_text = sys.argv[1]

text = io.open(input_text, "r", encoding="utf-8").read()

tag_items = re.findall(r"<.*?>", text, re.DOTALL)
tag_items_len = 0
for i in tag_items:
    tag_items_len = tag_items_len + len(i)

text_items = re.findall(r">.*?<", text, re.DOTALL)
text_items_len = 0
for i in text_items:
    # print(i[1:-1])
    text_items_len = text_items_len + len(i[1:-1])

tag_text_ratio = tag_items_len / len(text)

print("Länge des Texts: " + str(len(text)) + " Zeichen")
print("Anzahl der reinen Textzeichen: " + str(text_items_len))
print("Anzahl der Zeichen der Tags: " + str(tag_items_len))
print("Anteil der Tag-Zeichen am Gesamttext: " + str(tag_text_ratio))

