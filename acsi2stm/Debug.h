/* ACSI2STM Atari hard drive emulator
 * Copyright (C) 2019-2021 by Jean-Matthieu Coulon
 *
 * This Library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This Library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef DEBUG_H
#define DEBUG_H

#include "acsi2stm.h"

// Debug output functions

#if ACSI_DEBUG
template<typename T>
inline void acsiDbg(T txt) {
  Serial.print(txt);
  Serial.flush();
}

template<typename T, typename F>
inline void acsiDbg(T txt, F fmt) {
  Serial.print(txt, fmt);
  Serial.flush();
}

template<typename T>
inline void acsiDbgln(T txt) {
  Serial.println(txt);
  Serial.flush();
}

template<typename T, typename F>
inline void acsiDbgln(T txt, F fmt) {
  Serial.println(txt, fmt);
  Serial.flush();
}

static void acsiDbgDump(const void *data_, int size, int maxSize = ACSI_DUMP_LEN) {
  const uint8_t *data = (const uint8_t *)data_;
  acsiDbg('(');
  acsiDbg(size);
  acsiDbg(" bytes)");

  if(maxSize) {
    int dumpSize = size;
    if(maxSize > 0 && maxSize < size)
      dumpSize = maxSize;

    acsiDbg(':');
    for(int i = 0; i < dumpSize; ++i) {
      acsiDbg(' ');
      acsiDbg(data[i], HEX);
    }

    if(size > maxSize)
      acsiDbg(" [...]");
  }
}

static void acsiDbgDumpln(const void *data, int size, int maxSize = ACSI_DUMP_LEN) {
  acsiDbgDump(data, size, maxSize);
  acsiDbgln("");
}
#else
template<typename T>
inline void acsiDbg(T txt) {
}

template<typename T, typename F>
inline void acsiDbg(T txt, F fmt) {
}

template<typename T>
inline void acsiDbgln(T txt) {
}

template<typename T, typename F>
inline void acsiDbgln(T txt, F fmt) {
}

static void acsiDbgDump(const void *, int) {
}

static void acsiDbgDump(const void *, int, int) {
}

static void acsiDbgDumpln(const void *, int) {
}

static void acsiDbgDumpln(const void *, int, int) {
}
#endif

// Verbose output
#if ACSI_VERBOSE
template<typename ...T>
inline void acsiVerbose(T... txt) {
  acsiDbg(txt...);
}

template<typename ...T>
inline void acsiVerboseln(T... txt) {
  acsiDbgln(txt...);
}

static void acsiVerboseDump(const void *data, int size, int maxSize = ACSI_DUMP_LEN) {
  acsiDbgDump(data, size, maxSize);
}

static void acsiVerboseDumpln(const void *data, int size, int maxSize = ACSI_DUMP_LEN) {
  acsiDbgDumpln(data, size, maxSize);
}
#else
template<typename ...T>
inline void acsiVerbose(T... txt) {
}

template<typename ...T>
inline void acsiVerboseln(T... txt) {
}

static void acsiVerboseDump(const void *data, int size, int maxSize = ACSI_DUMP_LEN) {
}

static void acsiVerboseDumpln(const void *data, int size, int maxSize = ACSI_DUMP_LEN) {
}
#endif

template<typename T>
inline void acsiDbgl(T txt) {
  acsiDbgln(txt);
}

template<typename T, typename... More>
inline void acsiDbgl(T txt, More... more) {
  acsiDbg(txt);
  acsiDbgl(more...);
}

template<typename T>
inline void acsiVerbosel(T txt) {
  acsiVerboseln(txt);
}

template<typename T, typename... More>
inline void acsiVerbosel(T txt, More... more) {
  acsiVerbose(txt);
  acsiVerbosel(more...);
}

#endif
