BEGIN {
	print "/* Automatically generated by generate-cmdlist.awk */\n"
	print "struct cmdname_help {"
	print "\tchar name[16];"
	print "\tchar help[80];"
	print "\tunsigned char group;"
	print "};\n"
	print "static char *common_cmd_groups[] = {"
}
/### common groups/ {
	state = 1
}
/### command list/ {
	print "};\n\nstatic struct cmdname_help common_cmds[] = {"
	state = 2
}
/^#/ || /^[ 	]*$/ { next }
state == 2 {
	for (i = 2; i <= NF; i++)
		if (grp[$i]) {
			f = "Documentation/"$1".txt"
			while (getline s <f > 0)
				if (match(s, $1" - ")) {
					t = substr(s, length($1" - ") + 1)
					break
				}
			close(f)
			printf "\t{\"%s\", N_(\"%s\"), %s},\n",
				substr($1, length("git-") + 1), t, grp[$i] - 1
			break
		}
}
state == 1 {
	grp[$1] = ++n
	sub($1"[ 	][ 	]*", "")
	printf "\tN_(\"%s\"),\n", $0
}

END { print "};" }