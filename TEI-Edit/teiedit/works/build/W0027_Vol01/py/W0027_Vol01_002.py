#!/usr/bin/python
#-*- coding: utf-8 -*-
import re
from lxml import etree
from io import BytesIO
import json
import time

start = time.time()

"""
18.06.26 CR

This script resolves abbreviations using a dictionary created from manually corrected texts.
Only abbreviations that have been manually resolved by our editors are used. These have been reviewed and cleaned up to remove any ambiguous cases.
See examples: "D:\Cindy\SVN\trunk\teiedit\works\resources\Abbr-Extraction\AmbiguousAbbr.txt" 

Purpose: Processing TEI-Tite files, finding abbreviations from dictionary, and tagging them as:
        <abbr rend="choice" resp="#auto">'
        <abbr rend="abbr">[abbreviation]</abbr>'
        <abbr rend="expan" resp="#CR #auto #PYD">expansion</abbr>'
        </abbr>.

- Dictionary of abbreviations and their expansions
  extracted from texts manually corrected:
  
  "D:\Cindy\SVN\trunk\teiedit\works\resources\Abbr-Extraction\LA-abbr-expan-Dictionary.txt"
  
- A python-like dictionary was made using the script:
  "D:\Cindy\SVN\trunk\teiedit\works\resources\Abbr-Extraction\py\LA-expan-dict2pyFormat.py"
- The resulting python-dictionary:
  "[SVN]trunk\teiedit\works\resources\Abbr-Extraction\LA-abbr-expan-Dictionary-py-format.txt"
  
"""

# 1) Input text
text = open("D:/SVN/trunk/teiedit/works/build/W0027_Vol01/xml/W0027_Vol01_002.xml", encoding='utf-8').read()

# 2) Load Python dictionary of abbreviations
with open('D:/SVN/trunk/teiedit/works/resources/Abbr-Extraction/LA-abbr-expan-Dictionary-py-format.txt', 'r', encoding='utf-8') as f:
    abbr_dictionary = json.load(f)

# ---- DIAGNOSTIC ----
print(f"Total entries in dictionary: {len(abbr_dictionary)}")
print("First 5 entries:")
for k, v in list(abbr_dictionary.items())[:5]:
    print(f"  '{k}' -> '{v}'")

# 3) Processing input-text
text_output = text
keys_sorted = sorted(abbr_dictionary.keys(), key=len, reverse=True)

# Character class to consider "word" characters for your texts (letters with accents, digits, underscore)
CHAR = r"A-Za-zÀ-ÖØ-öø-ÿ0-9æœſçããāāēēẽẽđõõōōũũūūq́́⁊t̃ꝰr̃r̄̈ꝑꝓ"

# First pass: replace only whole-token matches with placeholders to avoid nested replacements
for i, word in enumerate(keys_sorted):
    esc_word = re.escape(word)
    # match only if NOT preceded or followed by a letter/digit/underscore (i.e., whole token)
    # AND NOT followed by a hyphen "-"
    pattern = rf'(?<![{CHAR}])({esc_word})(?![{CHAR}\-=]|[\-=]\s*<)'
    placeholder = f'@@REPL_{i}@@'
    # Here we replace only exact matches
    text_output = re.sub(pattern, placeholder, text_output)

# Second pass: replace placeholders with final XML
for i, word in enumerate(keys_sorted):
    replacement = abbr_dictionary[word]
    xml_final = (
        f'<abbr rend="choice" resp="#auto">'
        f'<abbr rend="abbr">{word}</abbr>'
        f'<abbr rend="expan" resp="#CR #auto #PYD">{replacement}</abbr>'
        f'</abbr>'
    )
    text_output = text_output.replace(f'@@REPL_{i}@@', xml_final)

# ---- DIAGNOSTIC ----
if text == text_output:
    print("\n>>> The text was NOT modified")
else:
    print("\n>>> OK: The text was modified correctly")

# 4) Save output file
with open('D:/SVN/trunk/teiedit/works/build/W0027_Vol01/xml/W0027_Vol01_003.xml', 'w', encoding='utf-8') as out_f:
    out_f.write(text_output)

end = time.time()
total = end - start

print(f"\n>>> Processing time: {total:.2f} seconds")

if __name__ == "__main__":
    pass
