#!/usr/bin/python
#-*- coding: utf-8 -*-
import re
from lxml import etree
from io import BytesIO
import json
import time
from datetime import timedelta


start = time.time()

"""
Run 22.07.26

-----------------------
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
text = open("D:/Cindy/SVN/trunk/teiedit/works/build/W0027_Vol02/xml/W0027_Vol02_002.xml", encoding='utf-8').read()

# 2) Load Python dictionary of abbreviations
with open('D:/Cindy/SVN/trunk/teiedit/works/resources/Abbr-Extraction/LA-abbr-expan-Dictionary-py-format.txt', 'r', encoding='utf-8') as f:
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
    # AND NOT followed by a hyphen "-" "-<lb type="nb"/>"
    pattern = rf'(?<![{CHAR}])({esc_word})(?![{CHAR}\-=]|[\-=]\s*<)'
    placeholder = f'@@REPL_{i}@@'

    # Find all matches
    matches = list(re.finditer(pattern, text_output))

    # Process matches in reverse order to avoid position shifts
    for match in reversed(matches):
        start_pos = match.start()
        end_pos = match.end()

        # Get context before and after (-<lb type="nb"/>)
        context_before = text_output[max(0, start_pos - 30):start_pos]
        context_after = text_output[end_pos:min(len(text_output), end_pos + 20)]

        # Skip if preceded by -<lb type="nb"/>
        if '-<lb type="nb"/>' in context_before or re.search(r'-<lb\s+type="nb"/>\s*$', context_before):
            continue

        # Skip if followed by -<lb type="nb"/>
        if '-<lb type="nb"/>' in context_after or re.search(r'^\s*-<lb\s+type="nb"/>', context_after):
            continue

        # Only replace if validation passed
        text_output = text_output[:start_pos] + placeholder + text_output[end_pos:]

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
    print("\n>>> Check with xpath '//abbr[@rend eq 'expan']' in the output file to see how many expansions were tagged.")

# 4) Save output file
with open('D:/Cindy/SVN/trunk/teiedit/works/build/W0027_Vol02/xml/W0027_Vol02_003.xml', 'w', encoding='utf-8') as out_f:
    out_f.write(text_output)

end = time.time()
total = end - start
tiempo_formateado = str(timedelta(seconds=total)).split('.')[0]

print(f"\n>>> Processing time: {tiempo_formateado}")

if __name__ == "__main__":
    pass
