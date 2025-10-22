//	For logging to hls-proxy console use:
//	globals.error('Your text of message');
//

// Playlist is available in m3u8 variable as Buffer object

const lines = m3u8.toString().split('\n');

for (let i = 0; i < lines.length; i++) {
	const line = lines[i];

	if (line.startsWith('http://127.0.0.1:6878')) {
		const replacedLine = line.replace('http://127.0.0.1:6878', 'http://192.168.68.77:6878');
                print(replacedLine + '\n');
	}
	else {
		print(line + '\n');
	}
}
