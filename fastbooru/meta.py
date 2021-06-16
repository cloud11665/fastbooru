from argparse import RawDescriptionHelpFormatter
import os

class MetaVarlessFormatter(RawDescriptionHelpFormatter):
	def _format_action_invocation(self, action):
		if not action.option_strings:
			default = self._get_default_metavar_for_positional(action)
			metavar, = self._metavar_formatter(action, default)(1)
			return metavar
		else:
			parts = []

			if action.nargs == 0:
				parts.extend(action.option_strings)

			else:
				default = self._get_default_metavar_for_optional(action)
				args_string = self._format_args(action, default)
				for option_string in action.option_strings:
					parts.append(option_string)
				return '%s %s' % (', '.join(parts), args_string)

		return ', '.join(parts)

	def _get_default_metavar_for_optional(self, action):
		return action.dest.upper()

HAS_CURL = os.system(f"curl -SV > {os.devnull} 2>&1") != 0