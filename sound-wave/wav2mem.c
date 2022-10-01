//  Copyright (C) 2022  Tristan Itschner
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

#define DR_WAV_IMPLEMENTATION
#include "dr_wav.h"
#include <inttypes.h>

void print_help(void) {
	printf("Usage: ./wav2mem [.wav file] [bits per sample]\n");
	printf("Bits per sample are optional, default is 16.\n");
}


int main(int argc, char ** argv)
{
    drwav wav;
	if (argc < 2) {
		printf("Please provide input file...\n");
		print_help();
		exit(1);
	}
    if (!drwav_init_file(&wav, argv[1], NULL)) {
		printf("Couldn't open input file...\n");
		print_help();
        return -1;
    }

	int bits_used = 16;
	if (argc == 3) {
		bits_used = atoi(argv[2]);
	}

	size_t nsamples = (size_t) wav.totalPCMFrameCount;
    int32_t* pSampleData = (int32_t*)malloc(nsamples * wav.channels * sizeof(int32_t));
    drwav_read_pcm_frames_s32(&wav, wav.totalPCMFrameCount, pSampleData);

	for(int i = 0; i < nsamples; i++)
		printf("%04x\n", ((pSampleData[i*wav.channels] >> (16 + (16 - bits_used)))) + (1 << (bits_used-1))); // only care about one channel

    drwav_uninit(&wav);
    return 0;
}
