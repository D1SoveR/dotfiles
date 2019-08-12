#!/usr/bin/env python3
import atexit
import os
import readline
import sys

def register_readline():

	if "XDG_CACHE_HOME" in os.environ:
		history_path = os.path.join(os.environ["XDG_CACHE_HOME"], "python_history")
	else:
		history_path = os.path.join(os.environ["HOME"], ".cache", "python_history")

	try:
		readline.read_history_file(history_path)
		h_len = readline.get_current_history_length()
	except FileNotFoundError:
		open(history_path, "wb").close()
		h_len = 0

	def save(prev_h_len, histfile):
		new_h_len = readline.get_current_history_length()
		readline.set_history_length(1000)
		readline.append_history_file(new_h_len - prev_h_len, histfile)

	atexit.register(save, h_len, history_path)

sys.__interactivehook__ = register_readline
