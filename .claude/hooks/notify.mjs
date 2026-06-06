// Stop hook. Fires when Claude finishes a turn. Pings so you can look away and come back.
// Cross-platform (Node): terminal bell + a marker line.
process.stdout.write("\x07");
process.stdout.write("✅ Claude finished.\n");
process.exit(0);
