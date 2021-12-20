/* AMX Mod X
*	BSP File include
*
* Author: the_hunter
* Version: 1.0
*
* If you find a bug or you have ideas/suggestion,
* you can mail me at Telegram https://t.me/the_hunter1
*
* This file is provided as is (no warranties)
*/

#if defined _bspfile_included
	#endinput
#endif
#define _bspfile_included

#include <amxmodx>


#define Q1BSP_VERSION	29	// quake1 regular version (beta is 28)
#define HLBSP_VERSION	30	// half-life regular version

enum _:BspHeader (+= 4)
{
	bsp_version = 0,
	bsp_lump_entities_offset,
	bsp_lump_entities_size,
	bsp_lump_planes_offset,
	bsp_lump_planes_size,
	bsp_lump_textures_offset,
	bsp_lump_textures_size,
	bsp_lump_vertexes_offset,
	bsp_lump_vertexes_size,
	bsp_lump_visibility_offset,
	bsp_lump_visibility_size,
	bsp_lump_nodes_offset,
	bsp_lump_nodes_size,
	bsp_lump_texinfo_offset,
	bsp_lump_texinfo_size,
	bsp_lump_faces_offset,
	bsp_lump_faces_size,
	bsp_lump_lighting_offset,
	bsp_lump_lighting_size,
	bsp_lump_clipnodes_offset,
	bsp_lump_clipnodes_size,
	bsp_lump_leafs_offset,
	bsp_lump_leafs_size,
	bsp_lump_marksurfaces_offset,
	bsp_lump_marksurfaces_size,
	bsp_lump_edges_offset,
	bsp_lump_edges_size,
	bsp_lump_surfedges_offset,
	bsp_lump_surfedges_size,
	bsp_lump_models_offset,
	bsp_lump_models_size,
	bsp_header_lumps_offset,
	bsp_header_lumps_size
};

static stock g_hFileBsp;
static stock g_iFileSize;


/**
 * Gets the BSP file path by map name.
 *
 * @param szMap			A map name.
 * @param szPath		Buffer to copy path to.
 * @param iMaxLen		Maximum buffer size.
 * @param szError		An error string (if any).
 * @param iErrLen		An error string max length.
 *
 * @return              Number of cells written.
 */
bsp_get_path(const szMap[], szPath[], iMaxLen, szError[] = "", iErrLen = 0)
{
	// POSIX-oriented OSes are case sensitive.
	// So we have to find bsp file via next_file() function.

	new FileType:type;
	new iCellsWritten = 0;
	new szFileName[MAX_NAME_LENGTH + 4]; // + 4 for extension (.bsp)
	new hDir = open_dir("maps", szFileName, charsmax(szFileName), type);

	if (hDir == 0)
	{
		copy(szError, iErrLen, "Could not open ^"maps^" directory.");
		return 0;
	}

	new szMapBsp[MAX_NAME_LENGTH + 4];
	formatex(szMapBsp, charsmax(szMapBsp), "%s.bsp", szMap);

	do
	{
		if (type == FileType_File && equali(szFileName, szMapBsp))
		{
			iCellsWritten = formatex(szPath, iMaxLen, "maps/%s", szFileName);
			break;
		}
	}
	while (next_file(hDir, szFileName, charsmax(szFileName), type));

	if (iCellsWritten == 0)
		copy(szError, iErrLen, "Could not find bsp path.");

	close_dir(hDir);

	return iCellsWritten;
}


/**
 * Opens BSP file for a reading.
 *
 * @note The BSP file version should be 30 (half-life regular version).
 *
 * @param szBspFile		Path to file.
 * @param szError		An error string (if any).
 * @param iErrLen		An error string max length.
 *
 * @return              A file handle, or 0 if the file could not be opened.
 */
stock bsp_open(const szBspFile[], szError[] = "", iErrLen = 0)
{
	g_iFileSize = 0;
	g_hFileBsp = fopen(szBspFile, "rb");

	if (g_hFileBsp == 0)
	{
		formatex(szError, iErrLen, "Could not open file ^"%s^".", szBspFile);
		return 0;
	}

	new iBspVersion = -1;
	g_iFileSize = file_size(szBspFile, FSOPT_BYTES_COUNT);

	if (g_iFileSize <= 0)
	{
		bsp_close();
		formatex(szError, iErrLen, "File is empty.");

		return 0;
	}

	if (fseek(g_hFileBsp, bsp_version, SEEK_SET) == 0 && !FileReadInt32(g_hFileBsp, iBspVersion))
	{
		bsp_close();
		formatex(szError, iErrLen, "Failed reading file.");

		return 0;
	}

	if (iBspVersion != HLBSP_VERSION)
	{
		bsp_close();
		formatex(szError, iErrLen, "BSP file has wrong version number (%d should be %d).", iBspVersion, HLBSP_VERSION);

		return 0;
	}

	return g_hFileBsp;
}


/**
 * Tests whether a string is found inside LUMP_ENTITIES data with case ignoring.
 *
 * @note Maximum string length is 34 bytes.
 *
 * @param szString		String to search in.
 *
 * @return              true if match found, false otherwise
 */
stock bool:bsp_lump_ent_containi(const szString[])
{
	new iOffset, iSize;

	if (!get_lump_entities_offset(iOffset, iSize))
		return false;

	new szBuffer[MAX_NAME_LENGTH + 2];
	new iStringLen = strlen(szString);

	for (new i = 0; i < iSize; i++)
	{
		fseek(g_hFileBsp, iOffset + i, SEEK_SET);
		fread_blocks(g_hFileBsp, szBuffer, iStringLen, BLOCK_CHAR);

		if (equali(szBuffer, szString))
			return true;
	}

	return false;
}


/**
 * Counts the string occurrences inside LUMP_ENTITIES data with case ignoring.
 *
 * @note It may be useful for counting spawn points, hostages, etc.
 *
 * @note Maximum string length is 34 bytes.
 *
 * @param szString		String to search in.
 *
 * @return              Number of occurrences found.
 */
stock bsp_lump_ent_counti(const szString[])
{
	new iOffset, iSize;

	if (!get_lump_entities_offset(iOffset, iSize))
		return false;

	new iCount = 0;
	new szBuffer[MAX_NAME_LENGTH + 2];
	new iStringLen = strlen(szString);

	for (new i = 0; i < iSize; i++)
	{
		fseek(g_hFileBsp, iOffset + i, SEEK_SET);
		fread_blocks(g_hFileBsp, szBuffer, iStringLen, BLOCK_CHAR);
		equali(szBuffer, szString) && ++iCount;
	}

	return iCount;
}


/**
 * Gets count of the bomb sites on the map.
 *
 * @return                  Bomb sites count
 */
stock bsp_bombplace_get_count()
{
	new iOffset, iSize;

	if (!get_lump_entities_offset(iOffset, iSize))
		return 0;

	new iCount = 0;
	new iDataLen = 0;
	new szBuffer[MAX_FMT_LENGTH]; // it should be enough
	new szTarget[MAX_NAME_LENGTH];
	new Trie:trFoundTargets = TrieCreate();

	new ch, iEndOfFile = iOffset + iSize;
	fseek(g_hFileBsp, iOffset, SEEK_SET);

	while (ftell(g_hFileBsp) < iEndOfFile)
	{
		ch = fgetc(g_hFileBsp);
		if (ch == -1) break; // something wrong

		if (ch == '{')
		{
			iDataLen = read_ent_data_block(szBuffer, MAX_FMT_LENGTH - 1);

			if (get_func_bomb_target(szBuffer, iDataLen, szTarget))
			{
				if (!TrieKeyExists(trFoundTargets, szTarget))
				{
					TrieSetCell(trFoundTargets, szTarget, 0, false);
					++iCount;
				}
			}
		}
	}
	TrieDestroy(trFoundTargets);

	return iCount;
}


/**
 * Closes a BSP file handle (if is opened).
 *
 * @noreturn
 */
stock bsp_close()
{
	if (g_hFileBsp)
	{
		fclose(g_hFileBsp);
		g_hFileBsp = 0;
	}
}


static stock get_lump_entities_offset(&iOffset, &iSize)
{
	return fseek(g_hFileBsp, bsp_lump_entities_offset, SEEK_SET) == 0 &&
		FileReadInt32(g_hFileBsp, iOffset) &&
		FileReadInt32(g_hFileBsp, iSize) &&
		iSize < (g_iFileSize - iOffset);
}


static stock read_ent_data_block(szBuffer[], iMaxLen)
{
	new iCount = 0;
	new ch = fgetc(g_hFileBsp);

	while (ch != '}' && ch != -1 && iCount < iMaxLen)
	{
		szBuffer[iCount++] = ch;
		ch = fgetc(g_hFileBsp);
	}
	szBuffer[iCount] = EOS;

	return iCount;
}


static stock get_func_bomb_target(const szData[], iDataLen, szTarget[MAX_NAME_LENGTH])
{
	if (containi(szData, "^"func_bomb_target^"") == -1)
		return 0;

	new iPos = 0;
	new szKey[MAX_NAME_LENGTH];
	new szValue[MAX_NAME_LENGTH];

	while (iPos < iDataLen)
	{
		iPos = argparse(szData, iPos, szKey, MAX_NAME_LENGTH - 1);
		if (iPos == -1) break;

		if (equali(szKey, "target"))
		{
			iPos = argparse(szData, iPos, szValue, MAX_NAME_LENGTH - 1);
			if (iPos == -1) break;

			return copy(szTarget, MAX_NAME_LENGTH - 1, szValue);
		}
	}

	return 0;
}
