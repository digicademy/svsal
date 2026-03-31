#!/usr/bin/python
#-*- coding: utf-8 -*-
import re

"""
Abbreviations with <lb>
 
e.g.:
 REGEX
 (\s)(\w+)(<lb rendition="#hyphen" break="no" )(xml:id=")([\d\w-]+"/>)(\w+)(<g ref="#charu0303">ũ</g>)(\s)
 
 finds for instance:
 [space here ]pre<lb rendition="#hyphen" break="no" xml:id="W0043-07-0024-lb-2043"/>ti<g ref="#charu0303">ũ</g>[space here ]
 
 and it is marked in an expansion as:
 [space here ]<choice>
  <abbr>pre<lb rendition="#hyphen" break="no" xml:id="W0043-07-0024-lb-2043"/>ti<g ref="#charu0303">ũ</g></abbr>
  <expan resp="#CR #auto">pre<lb rendition="#hyphen" break="no" sameAs="#W0043-07-0024-lb-2043"/>tium</expan>
  </choice>[space here ]
  
  group(1)<choice><abbr>group(2)group(3)group(4)group(5)group(6)group(7)</abbr><expan resp="#CR">que</expan></choice>

IMPORTANT.

All patterns are saved in a dictionary with regular expressions as key and replacement as value = see variable "cases"
The items in dictinary are only used in case there is no ambiguity with the regex.
Make sure spaces, special characters and punctuation marks used as word boundaries are not deleted.

Example of files used:
input = D:/Cindy/SVN/trunk/teiedit/works/build/W0043_Vol07/xml/W0043_Vol07_011.xml
script = file:/D:/Cindy/SVN/trunk/teiedit/works/build/W0043_Vol07/py/W0043-abbr-lb.py
output = D:/Cindy/SVN/trunk/teiedit/works/build/W0043_Vol07/xml/W0043_Vol07_012.xml

Replace line 111 with the respective <change> e.g.: 
 
 '<listChange ordered="true">\n                ' : '<listChange ordered="true">\n                <change who="#CR #auto" when="YYYY-MM-DD" status="a_raw" xml:id="W0XXX_VolXX_change_XXX" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>\n                ', 
"""

# 1. read text as as string giving the exact location in SVN. Change the path according to the file location.
# In SVN should be: text = open("D:/Cindy/SVN/trunk/teiedit/works/build/W0043_Vol07b/xml/W0043_Vol07_011.xml",encoding='utf-8').read()
#text = open("D:/Cindy/AbbrWithPython/W0043_Vol07b/xml/W0043_Vol07_011.xml", encoding='utf-8').read()
#text = open("D:/Cindy/SVN/trunk/teiedit/works/build/W0006_Vol01/xml/W0006_Vol01_012.xml",encoding='utf-8').read()
text = open("D:/Cindy/SVN/trunk/teiedit/works/build/W0005_Vol01/xml/W0005_Vol01_017.xml", encoding='utf-8').read()

# 2. (Optional) look for possible new cases with findall().

#choice = re.findall(r'( )(\w+)(<lb rendition=\"#hyphen\" break=\"no\" )(xml:id=\")([\d\w-]+\"/>)(\w+)(<g ref=\"#charu0303\">ũ</g>)([\.,;:\?! ])', text)
#choice = re.findall(r'( )(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<lb break=\"no\" rendition=\"#\w+\" )(xml:id=\")([\d\w-]+\"/>)(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<g ref=\"#charo0304\">ō</g>|<g ref=\"#charo0303\">õ</g>)(e|es|e<g ref=\"#char017f\">ſ</g>)([\.,;:\?! ])', text)

#print('Number of cases found with the pattern: ', len(choice))
#print(choice)

# Latin patterns in regular expressions (key) saved as variables e.g. "final_um"
# Most of them taken from SVN/trunk/teiedit/works/resources/templates/xsl/expandAbbreviations_LA_regex_TEItite.xsl and added <lb break="no" [...]>
# <lb xml:id="..." break="no" rendition="#\w+" resp="#auto"/> was not taken into account, since these words are the ones
# annotated automatically with the dictionary, which doesn't have abbreviations.

final_um = '( )(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<lb rendition=\"#\w+\" break=\"no\" |<lb break=\"no\" rendition=\"#\w+\" )(xml:id=\")([\d\w-]+\"/>)(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<g ref=\"#charu0303\">ũ</g>)([\.,;:\?! ])'

final_am = '( )(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<lb rendition=\"#\w+\" break=\"no\" |<lb break=\"no\" rendition=\"#\w+\" )(xml:id=\")([\d\w-]+\"/>)(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<g ref=\"#chara0303\">ã</g>|<g ref=\"#chara0304\">ā</g>)([\.,;:\?! ])'

antur = '( )(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<g ref=\"#chara0303\">ã</g>|<g ref=\"#chara0304\">ā</g>)(<lb rendition=\"#\w+\" break=\"no\" |<lb break=\"no\" rendition=\"#\w+\" )(xml:id=\")([\d\w-]+\"/>)(di|dum|t|ti|tibus|tis|tur)([, \?!\(\)\.]+)'

pro = '( )(<g ref="#chara753">ꝓ</g>)(<lb rendition=\"#\w+\" break=\"no\" |<lb break=\"no\" rendition=\"#\w+\" )(xml:id=\")([\d\w-]+\"/>)(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)([, \?!\(\)\.]+)'

prowlb = '( )(<g ref="#chara753">ꝓ</g>)(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<lb rendition=\"#\w+\" break=\"no\" |<lb break=\"no\" rendition=\"#\w+\" )(xml:id=\")([\d\w-]+\"/>)(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)([, \?!\(\)\.]+)'

final_us = '( )(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<lb break=\"no\" rendition=\"#\w+\" |<lb rendition=\"#\w+\" break=\"no\" )(xml:id=\")([\d\w-]+\"/>)(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<g ref="#chara770">ꝰ</g>)([\.,;:\?! ])'

on_cdfs = '( )(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<g ref=\"#charo0304\">ō</g>|<g ref=\"#charo0303\">õ</g>)(<lb rendition=\"#\w+\" break=\"no\" |<lb break=\"no\" rendition=\"#\w+\" )(xml:id=\")([\d\w-]+\"/>)(c|d|f|s|<g ref=\"#char017f\">ſ</g>+|t)(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)([\.,;:\?! ])'

ones = '( )(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<lb rendition=\"#\w+\" break=\"no\" |<lb break=\"no\" rendition=\"#\w+\" )(xml:id=\")([\d\w-]+\"/>)(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<g ref=\"#charo0304\">ō</g>|<g ref=\"#charo0303\">õ</g>)(e|es|e<g ref=\"#char017f\">ſ</g>)([\.,;:\?! ])'

untur = '( )(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<g ref=\"#charu0303\">ũ</g>)(<lb rendition=\"#\w+\" break=\"no\" |<lb break=\"no\" rendition=\"#\w+\" )(xml:id=\")([\d\w-]+\"/>)(t|tur)([\.,;:\?! ])'

entur = '( )(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<g ref="#chare0303">ẽ</g>|<g ref="#chare0304">ē</g>)(<lb rendition=\"#\w+\" break=\"no\" |<lb break=\"no\" rendition=\"#\w+\" )(xml:id=\")([\d\w-]+\"/>)(da|dam|di|dis|dus|sis|t|te|tia|tiam|tias|tur)([\.,;:\?! ])'

em_pmb = '( )(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<g ref="#chare0303">ẽ</g>|<g ref="#chare0304">ē</g>)(<lb rendition=\"#\w+\" break=\"no\" |<lb break=\"no\" rendition=\"#\w+\" )(xml:id=\")([\d\w-]+\"/>)(b|m|p)(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)([\.,;:\?! ])'

final_que = '( )(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(<lb break=\"no\" rendition=\"#\w+\" |<lb rendition=\"#\w+\" break=\"no\" )(xml:id=\")([\d\w-]+\"/>)(\w+|\w+<g ref=\"#char00e6\">æ</g>\w+|\w+<g ref=\"#char0153\">œ</g>\w+|\w+<g ref=\"#chare0328\">ę</g>\w+|<g ref=\"#char017f\">ſ</g>+\w+|\w+<g ref=\"#charc0327\">ç</g>\w+)(q;|q́;|́|)([\.,;:\?! ])'

# 3 Dictionary with regular expressions:
# key as the variable name e.g. "final_um" :
# and value as replacement '\g<1><choice><abbr>\g<2>\g<3>\g<4>\g<5>\g<6>\g<7></abbr><expan resp=\"#CRPY #auto\">\g<2>\g<3>sameAs=\"#\g<5>\g<6>um</expan></choice>\g<8>'

cases = {
    final_um : '\g<1><choice><abbr>\g<2>\g<3>\g<4>\g<5>\g<6>\g<7></abbr><expan resp=\"#CRPY #auto\">\g<2>\g<3>sameAs=\"#\g<5>\g<6>um</expan></choice>\g<8>',

    final_am : '\g<1><choice><abbr>\g<2>\g<3>\g<4>\g<5>\g<6>\g<7></abbr><expan resp=\"#CRPY #auto\">\g<2>\g<3>sameAs=\"#\g<5>\g<6>am</expan></choice>\g<8>',

    antur : '\g<1><choice><abbr>\g<2>\g<3>\g<4>\g<5>\g<6>\g<7></abbr><expan resp=\"#CRPY #auto\">\g<2>an\g<4>sameAs=\"#\g<6>\g<7></expan></choice>\g<8>',

    pro : '\g<1><choice><abbr>\g<2>\g<3>\g<4>\g<5>\g<6></abbr><expan resp=\"#CRPY #auto\">pro\g<3>sameAs=\"#\g<5>\g<6></expan></choice>\g<7>',

    prowlb : '\g<1><choice><abbr>\g<2>\g<3>\g<4>\g<5>\g<6>\g<7></abbr><expan resp=\"#CRPY #auto\">pro\g<3>\g<4>sameAs=\"#\g<6>\g<7></expan></choice>\g<8>',

    final_us : '\g<1><choice><abbr>\g<2>\g<3>\g<4>\g<5>\g<6>\g<7></abbr><expan resp=\"#CRPY #auto\">\g<2>\g<3>sameAs=\"#\g<5>\g<6>us</expan></choice>\g<8>',

    on_cdfs : '\g<1><choice><abbr>\g<2>\g<3>\g<4>\g<5>\g<6>\g<7>\g<8></abbr><expan resp=\"#CRPY #auto\">\g<2>on\g<4>sameAs=\"#\g<6>\g<7>\g<8></expan></choice>\g<9>',

    ones : '\g<1><choice><abbr>\g<2>\g<3>\g<4>\g<5>\g<6>\g<7>\g<8></abbr><expan resp=\"#CRPY #auto\">\g<2>\g<3>sameAs=\"#\g<5>\g<6>on\g<8></expan></choice>\g<9>',

    untur : '\g<1><choice><abbr>\g<2>\g<3>\g<4>\g<5>\g<6>\g<7></abbr><expan resp=\"#CRPY #auto\">\g<2>un\g<4>sameAs=\"#\g<6>\g<7></expan></choice>\g<8>',

    entur : '\g<1><choice><abbr>\g<2>\g<3>\g<4>\g<5>\g<6>\g<7></abbr><expan resp=\"#CRPY #auto\">\g<2>en\g<4>sameAs=\"#\g<6>\g<7></expan></choice>\g<8>',

    em_pmb : '\g<1><choice><abbr>\g<2>\g<3>\g<4>\g<5>\g<6>\g<7>\g<8></abbr><expan resp=\"#CRPY #auto\">\g<2>em\g<4>sameAs=\"#\g<6>\g<7>\g<8></expan></choice>\g<9>',

    final_que : '\g<1><choice><abbr>\g<2>\g<3>\g<4>\g<5>\g<6>\g<7></abbr><expan resp=\"#CRPY #auto\">\g<2>\g<3>sameAs=\"#\g<5>\g<6>que</expan></choice>\g<8>',

    '<listChange ordered="true">\n                ' : '<listChange ordered="true">\n                <change who="#CR #auto" when="2025-09-10" status="a_raw" xml:id="W0005_Vol01_change_024" xml:lang="en">Automatically expanded abbreviations with lb/@break using python.</change>\n                '
}

text_output = text
for word, replacement in cases.items():
    text_output = re.sub(word,replacement,text_output)
#

# 7. Save a xml copy with the new results.

"""W0043_Vol07_012_31Jul24 = open('D:/Cindy/AbbrWithPython/W0043_Vol07b/xml/W0043_Vol07_012_31Jul24.xml', 'w',encoding='utf-8')
W0043_Vol07_012_31Jul24.write(text_output)
W0043_Vol07_012_31Jul24.close()"""

"""
W0006_Vol01_013_prueba =open('C:/Users/cricocar/Downloads/W0006_Vol01_013_prueba.xml','w', encoding='utf-8')
W0006_Vol01_013_prueba.write(text_output)
W0006_Vol01_013_prueba.close()
"""
"""
W0006_Vol02_013_prueba =open('C:/Users/cricocar/Downloads/W0006_Vol02_013_prueba.xml','w', encoding='utf-8')
W0006_Vol02_013_prueba.write(text_output)
W0006_Vol02_013_prueba.close()"""


W0005_Vol01_018 =open('D:/Cindy/SVN/trunk/teiedit/works/build/W0005_Vol01/xml/W0005_Vol01_018.xml', 'w', encoding='utf-8')
W0005_Vol01_018.write(text_output)
W0005_Vol01_018.close()

expan_added = re.findall(r'#CRPY', text_output)

print("1 Check the <revisionDesc//listChange//change. Was this last step with python added?. If not, check line 113.")
print("2 Abbreviation with break added: ",len(expan_added))
print("3 Run the XPath //expan[@resp eq '#CRPY #auto'] in the output xml file to check the annotation of abbreviations with breaks.")

if __name__=="__main__":
    pass
