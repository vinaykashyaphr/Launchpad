import glob

# The purpose of this script is to allow a user to add to the dictionary used by the spell checker.
# Reasons for this being a separate script from the spellcheck:
# 1) This should be accessible to a limited set of users.
# 2) Inputs into launchpad arecibo while its running haven't worked well
# 3) A dedicated section would be nicer for the user, rather than being part of running arecibo

DICT_LOCATION = r'./launchpad/Arecibo_1/Dictionary/custom_dict.txt'
DICT_COLLECT = glob.glob('./launchpad/Arecibo_1/Dictionary/*.txt')

def dictionary_add(new_word):
    '''Add a word to the dictionary "custom_dict.txt"'''
    # check if word exists already in any of the dictionaries
    for dict_path in DICT_COLLECT:
        with open(dict_path) as dictionary:
            try:
                if new_word + '\n' in dictionary.read():
                    return new_word + " is already in the dictionary."
            except: # currently en_full.txt is unable to be checked so it skips
                pass
    # if not found, add it
    with open(DICT_LOCATION, 'a') as dictionary:
        dictionary.write(new_word + '\n')
    return new_word + " was added to the dictionary."

def dictionary_remove(old_word):
    '''Remove a word from the dictionary "custom_dict.txt"'''
    # check if word is in dictionary, can only remove from custom_dict.txt
    with open(DICT_LOCATION, 'r') as dictionary:
        lines = dictionary.readlines()
        if old_word + '\n' not in lines:
            return old_word + " was not found in the dictionary."
    # if word has been found, recreate text file without the word
    with open(DICT_LOCATION, 'w') as dictionary:
        for line in lines:
            if line.strip("\n") != old_word:
                dictionary.write(line)
    return old_word + " was removed from the dictionary. "

    