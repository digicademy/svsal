#!/usr/bin/env python
# 3.7.x
"""
This script merges multiple dictionaries with entries of the form "wordform > lemma" into one dictionary
while eliminating duplicate entries. Also, it tries to resolve multiple (different) mappings of identical
wordforms, such as "wordform > lemma1", "wordform > lemma2", by mapping their lemmata to one another; if that
fails, these entries are omitted, that is, the first entry wins (take a close look at the summaries and the error file!).
Therefore, manually curated dictionaries should be processed initially.
"""

import logging

logging.basicConfig(filename="errors.log", level=logging.INFO)

# dictionaries and paths are currently hard-coded for better control

path_to_dict_lat = '../../lat/wordforms-lat-full.txt'
path_to_dict_es = '../../es/wordforms-es.txt'
path_to_dict_translate = '../../wordforms-translate-edit.txt'

path_to_full_dict = 'result/wordforms-united.txt'


def normalize_space(lines):
    result = []
    for l in lines:
        line = ' '.join(l.split())
        result.append(line)
    return result


def normalize_and_map_lines(lines, result):
    remove_duplicate_lines = set(normalize_space(lines))
    strange_chars = 0
    multi_mappings = 0
    multi_lemma = 0
    multi_wordform = 0
    no_mappings = 0
    self_mappings = 0
    dupl_wordforms = 0
    dupl_wordforms_unresolved = 0
    translated_wordforms = 0
    for line in remove_duplicate_lines:
        tokens = line.split(' > ')
        # delete lines containing "_" or "+"
        if '+' in line or '_' in line:
            #print('Found line containing "+" or "_": "' + line + '" (skipping)')
            strange_chars += 1
        elif len(tokens) > 2:
            #print('Found line with more than one mapping: "' + line + '" (skipping)')
            multi_mappings += 1
        elif len(tokens) < 2:
            #print('Found line without valid mappings: "' + line + '" (skipping)')
            no_mappings += 1
        else:
            before = tokens[0]
            after = tokens[1]
            if before == after:
                # tested: word forms mapped to themselves (e.g., mancar > mancar) are redundant and can be removed
                #print('Found word form mapped to itself: "' + before + '" (skipping)')
                self_mappings += 1
            elif ' ' in after: # remove word form mapping to multiple lemmata
                #print('Found mapping of word form to multiple lemmata, in line: "' + line + '" (skipping)')
                multi_lemma += 1
            elif ' ' in before:
                #print('Found multiple word forms mapped to a single lemma, in line: "' + line + '" (skipping)')
                multi_wordform += 1
            else:
                if result.get(before):
                    logging.info('Word form is already mapped : "' + before + ' > ' + result[before]
                          + '", trying to map the previous to the current lemma: "'
                          + result[before] + ' > ' + after + '"')
                    if not result.get(result[before]):
                        result[before] = after
                    else:
                        logging.error('ERROR: Found similar wordforms, but could not map their lemmata: previous lemma "'
                              + result[before] +
                              '" is already mapped as word form itself, not mapping it to current lemma "'
                              + after + '"')
                        dupl_wordforms_unresolved += 1
                    dupl_wordforms += 1
                result[before] = after
    # logging
    print('-----------------------------------------------')
    print('Removed ' + str(len(lines) - len(remove_duplicate_lines)) + ' duplicate lines.')
    print('Removed ' + str(strange_chars) + ' lines containing "+" or "_".')
    print('Removed ' + str(multi_mappings) + ' lines with more than 1 " > " mapping.')
    print('Removed ' + str(no_mappings) + ' lines without any mappings.')
    print('Removed ' + str(self_mappings) + ' lines where a word form is mapped to itself.')
    print('Removed ' + str(multi_lemma) + ' lines where a word form is mapped to multiple lemmata at once.')
    print('Removed ' + str(multi_wordform) + ' lines where multiple word forms are mapped to a single lemma.')
    print('Created new mappings for the lemmata of ' + str(dupl_wordforms) + ' similar word forms.')
    print('Skipping ' + str(dupl_wordforms_unresolved) + ' similar word forms, since their respective lemmata could not be mapped '
          + ' to one another (see errors.log).')
    return result


entries = {}

print('Processing Spanish dictionary:')
es_dict = open(path_to_dict_es, 'r')
es_dict_lines = es_dict.read().split('\n')
es_entries = normalize_and_map_lines(es_dict_lines, entries)
es_dict.close()
print('------------------------------')

print('Processing Latin dictionary:')
lat_dict = open(path_to_dict_lat, 'r')
lat_dict_lines = lat_dict.read().split('\n')
lat_entries = normalize_and_map_lines(lat_dict_lines, entries)
lat_dict.close()
print('------------------------------')

print('Processing translation dictionary:')
trans_dict = open(path_to_dict_translate, 'r')
trans_dict_lines = trans_dict.read().split('\n')
trans_entries = normalize_and_map_lines(trans_dict_lines, entries)
trans_dict.close()
print('------------------------------')

# Final output
with open(path_to_full_dict, 'w') as full_dict:
    lines = []
    for key in sorted(entries.keys()):
        lines.append(key + ' > ' + entries[key])
    full_str = '\n'.join(lines)
    full_dict.write(full_str)
    full_dict.close()

print('MERGED ' + str(len(entries.keys())) + ' entries into final dictionary.')
