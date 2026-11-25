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
20.08.26 CR

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
text = open("D:/Cindy/SVN/trunk/teiedit/works/build/W0051_Vol03/xml/W0051_Vol03_002.xml", encoding='utf-8').read()

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
        context_before = text_output[max(0, start_pos - 6):start_pos]
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

# ---- NEW: Clean up abbr elements before <lb type="nb"/> ----
try:
    # Parse text_output as XML
    root = etree.fromstring(text_output.encode('utf-8'))

    # Find all abbr elements matching the XPath
    namespaces = {'': root.nsmap.get(None)}
    abbr_to_remove = root.xpath('//abbr[preceding-sibling::node()[1]/self::lb[@type eq "nb"]]')

    for abbr_elem in abbr_to_remove:
        # Check if this abbr has rend="choice"
        if abbr_elem.get('rend') == 'choice':
            # Find the child abbr with rend="abbr" and extract its text
            abbr_abbr_elem = abbr_elem.find('.//abbr[@rend="abbr"]')
            text_to_keep = abbr_abbr_elem.text if abbr_abbr_elem is not None else ''

            # Replace the abbr element with its text content
            parent = abbr_elem.getparent()
            if parent is not None:
                # Get the position of abbr_elem in parent
                index = list(parent).index(abbr_elem)
                # Get the previous sibling to attach text
                if index > 0:
                    prev_sibling = parent[index - 1]
                    if prev_sibling.tail is None:
                        prev_sibling.tail = text_to_keep
                    else:
                        prev_sibling.tail += text_to_keep
                else:
                    if parent.text is None:
                        parent.text = text_to_keep
                    else:
                        parent.text += text_to_keep

                # Remove the abbr element
                parent.remove(abbr_elem)

    # Convert back to string
    text_output = etree.tostring(root, encoding='unicode', method='xml')

except Exception as e:
    print(f"\n>>> Warning: Could not parse XML with lxml: {e}")
    print(">>> Continuing with regex-based cleanup instead...")

    # Fallback: regex-based cleanup
    # Remove <abbr rend="choice"> with nested <abbr> elements, keeping the abbr text
    pattern = r'<lb\s+type="nb"\s*/>\s*<abbr\s+rend="choice"[^>]*>[\s\n]*<abbr\s+rend="abbr"[^>]*>([^<]*)</abbr>[\s\n]*<abbr\s+rend="expan"[^>]*>[^<]*</abbr>[\s\n]*</abbr>'
    text_output = re.sub(pattern, r'<lb type="nb"/>\1', text_output)

# 4) Save output file
with open('D:/Cindy/SVN/trunk/teiedit/works/build/W0051_Vol03/xml/W0051_Vol03_003.xml', 'w', encoding='utf-8') as out_f:
    out_f.write(text_output)

end = time.time()
total = end - start
tiempo_formateado = str(timedelta(seconds=total)).split('.')[0]

print(f"\n>>> Processing time: {tiempo_formateado}")

if __name__ == "__main__":
    pass
