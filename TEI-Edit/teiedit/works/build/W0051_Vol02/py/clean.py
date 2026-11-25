#!/usr/bin/python
#-*- coding: utf-8 -*-
import re
from lxml import etree
from io import BytesIO
import json
import time
from datetime import timedelta

start = time.time()

# 1) Input text
textInput = open("D:/Cindy/SVN/trunk/teiedit/works/build/W0051_Vol02/xml/W0051_Vol02_003.xml", encoding='utf-8').read()

# ---- NEW: Clean up abbr elements before <lb type="nb"/> ----
try:
    # Parse text_output as XML
    root = etree.fromstring(textInput.encode('utf-8'))

    # Find all abbr elements matching the XPath
    namespaces = {'': root.nsmap.get(None)}
    abbr_to_remove = root.xpath('//abbr[preceding-sibling::node()[1]/self::lb[@type eq "nb"]]')

    print(f">>> Found {len(abbr_to_remove)} abbr elements to clean")

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
    text_output = etree.tostring(root, encoding='utf-8', method='xml').decode('utf-8')
    print(">>> XML cleanup completed successfully")

except Exception as e:
    print(f"\n>>> Warning: Could not parse XML with lxml: {e}")
    print(">>> Continuing with regex-based cleanup instead...")
    text_output = textInput

    # Fallback: regex-based cleanup
    # Remove <abbr rend="choice"> with nested <abbr> elements, keeping the abbr text
    pattern = r'<lb\s+type="nb"\s*/>\s*<abbr\s+rend="choice"[^>]*>[\s\n]*<abbr\s+rend="abbr"[^>]*>([^<]*)</abbr>[\s\n]*<abbr\s+rend="expan"[^>]*>[^<]*</abbr>[\s\n]*</abbr>'
    text_output = re.sub(pattern, r'<lb type="nb"/>\1', text_output)

# 4) Save output file - USE FORWARD SLASHES or RAW STRING
with open(r'D:/Cindy/SVN/trunk/teiedit/works/build/W0051_Vol02/xml\W0051_Vol02_004_clean.xml', 'w', encoding='utf-8') as out_f:
    out_f.write(text_output)

end = time.time()
total = end - start
tiempo_formateado = str(timedelta(seconds=total)).split('.')[0]

print(f"\n>>> Processing time: {tiempo_formateado}")
print(">>> Output saved to: C:\\Users\\cricocar\\Downloads\\W0051_Vol02_004_clean.xml")

if __name__ == "__main__":
    pass
