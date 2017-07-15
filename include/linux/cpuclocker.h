/*
 * Copyright (c) 2017  Lukas Berger
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

/* Samsung Galaxy S6 G92X EXYNOS 7420
 *   apollo cluster (little core)
 * 	{L0,  2000 * 1000},
 *	{L1,  1900 * 1000},
 *	{L2,  1800 * 1000},
 *	{L3,  1704 * 1000},
 *	{L4,  1600 * 1000},
 *	{L5,  1500 * 1000},
 *	{L6,  1400 * 1000},
 *	{L7,  1296 * 1000},
 *	{L8,  1200 * 1000},
 *	{L9,  1104 * 1000},
 *	{L10, 1000 * 1000},
 *	{L11,  900 * 1000},
 *	{L12,  800 * 1000},
 *	{L13,  700 * 1000},
 *	{L14,  600 * 1000},
 *	{L15,  500 * 1000},
 *	{L16,  400 * 1000},
 *	{L17,  300 * 1000},
 *	{L18,  200 * 1000},
 *
 *   atlas cluster (big core)
 *	{L0,  2496 * 1000},
 *	{L1,  2400 * 1000},
 *	{L2,  2304 * 1000},
 *	{L3,  2200 * 1000},
 *	{L4,  2100 * 1000},
 *	{L5,  2000 * 1000},
 *	{L6,  1896 * 1000},
 *	{L7,  1800 * 1000},
 *	{L8,  1704 * 1000},
 *	{L9,  1600 * 1000},
 *	{L10, 1500 * 1000},
 *	{L11, 1400 * 1000},
 *	{L12, 1300 * 1000},
 *	{L13, 1200 * 1000},
 *	{L14, 1100 * 1000},
 *	{L15, 1000 * 1000},
 *	{L16,  900 * 1000},
 *	{L17,  800 * 1000},
 *	{L18,  700 * 1000},
 *	{L19,  600 * 1000},
 *	{L20,  500 * 1000},
 *	{L21,  400 * 1000},
 *	{L22,  300 * 1000},
 *	{L23,  200 * 1000},
 *
 */


#include <mach/cpufreq.h>

#ifdef CONFIG_EXYNOS7420_UNDERCLOCK

    #define EXYNOS7420_CLUSTER0_MIN_LEVEL    L16 // 400 MHz
    #define EXYNOS7420_CLUSTER1_MIN_LEVEL    L17 // 800 MHz

#else

    #define EXYNOS7420_CLUSTER0_MIN_LEVEL    L16 // 400 MHz
    #define EXYNOS7420_CLUSTER1_MIN_LEVEL    L17 // 800 MHz

#endif

#ifdef CONFIG_EXYNOS7420_OVERCLOCK

	/*
	 * Some overclock-informations:
	 *
	 *  * If overclock is enabled, bus-tables (memory throughput MB/sec) get increased
	 *
	 *  * If overclock is enabled, voltages get increased up to
	 *     - +0.25V (+0.05V per level) compared to default voltage on cluster0
	 *     - +0.20V (+0.05V per level) compared to default voltage on cluster1
	 */

    #define EXYNOS7420_CLUSTER0_MAX_LEVEL    L3 // 1704 MHz
    #define EXYNOS7420_CLUSTER1_MAX_LEVEL    L2 // 2304 MHz

#else

    #define EXYNOS7420_CLUSTER0_MAX_LEVEL    L5 // 1500 MHz
    #define EXYNOS7420_CLUSTER1_MAX_LEVEL    L4 // 2100 MHz

#endif
