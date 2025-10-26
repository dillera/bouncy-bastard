# Build System Setup and Configuration

## Overview

This document describes the build system setup for the Bouncy Bastard cross-platform 8-bit client project. The project uses the **MekkoGX modular makefile framework** to build binaries for multiple retro computer platforms.

## Platforms Configured

Currently configured to build for:
- **Apple II** (cc65 toolchain)
- **Atari** (cc65 toolchain)
- **CoCo** (CMOC toolchain) - *requires additional setup*

Additional platforms available in the framework but not currently active:
- C64, Adam, MS-DOS, MSX, Dragon, PMD85, and others

## Build System Architecture

### Three-Layer Design

1. **Top-Level Makefile** (`Makefile`)
   - Project-specific configuration
   - Defines `PRODUCT`, `PLATFORMS`, `SRC_DIRS`, and `PLATFORM_COMBOS`
   - Single source of truth for what to build

2. **Mid-Level Makefiles** (`makefiles/`)
   - `toplevel-rules.mk` - Project-wide orchestration
   - `common.mk` - Shared compilation rules
   - `tc-common.mk` - Toolchain abstraction

3. **Platform & Toolchain Plugins**
   - `platforms/*.mk` - Platform-specific build rules
   - `toolchains/*.mk` - Compiler-specific rules

## Configuration Details

### Source Directories

```makefile
SRC_DIRS = src src/common src/%PLATFORM%
```

- `src/` - Main application entry point (main.c)
- `src/common/` - Shared code for all platforms
- `src/%PLATFORM%/` - Platform-specific implementations

### Include Directories

```makefile
EXTRA_INCLUDE = src/include src/common
EXTRA_INCLUDE_APPLE2 = src/apple2
EXTRA_INCLUDE_ATARI = src/atari
EXTRA_INCLUDE_COCO = src/coco
```

### FujiNet Library Integration

```makefile
FUJINET_LIB = 4.7.9
```

The FujiNet library (v4.7.9) is automatically downloaded and integrated for network support. The `fnlib.py` script handles:
- Downloading pre-built libraries
- Extracting platform-specific binaries
- Setting up include and library paths

## Build Process

### Building All Platforms

```bash
make clean
make
```

This builds executables and disk images for all configured platforms in the `r2r/` directory.

### Building Specific Platform

```bash
make apple2
make atari
make coco
```

### Platform-Specific Targets

```bash
make apple2/disk    # Build disk image only
make atari/r2r      # Build ready-to-run output
```

### Cleaning

```bash
make clean          # Remove all build artifacts
```

## Build Output

All build artifacts are organized by platform:

```
r2r/
  apple2/
    hello.a2s       # AppleSingle executable
    hello.po        # ProDOS disk image
  atari/
    hello.com       # Atari executable
  coco/
    hello.bin       # CoCo executable
    hello.dsk       # CoCo disk image

build/
  apple2/
    *.o             # Object files
    *.d             # Dependency files
    *.lst           # Assembly listings
  atari/
  coco/

_cache/
  fujinet-lib/      # Downloaded FujiNet library
  4.7.9-apple2/
  4.7.9-atari/
  4.7.9-coco/
  hirestxt-lib/     # Downloaded HiResTxt library (CoCo only)
  0.5.0/
    hirestxt.h      # Header file
    libhirestxt.a   # Static library
```

## Fixes Applied

### Apple II Compatibility

1. **Header File Fixes**
   - Changed `src/apple2/convert_chars.c` from `apple2enh.h` to `apple2.h`
   - Changed `src/apple2/delay.c` from `apple2enh.h` to `apple2.h`
   - Reason: Target is standard Apple II, not enhanced Apple II

2. **Missing Function Implementation**
   - Replaced `waitvsync()` call in `src/apple2/delay.c` with simple delay loop
   - Reason: `waitvsync()` is only available in enhanced Apple II

3. **Character Constants**
   - Added missing character constants to `src/apple2/get_line.c`:
     - `CH_DEL` (0x08) - Backspace
     - `CH_ENTER` (0x0D) - Enter/Return
     - `CH_CURS_LEFT` (0x08) - Cursor left

### CoCo Support

1. **HiResTxt Library Integration**
   - The CoCo build automatically downloads and integrates the hirestxt-mod library (v0.5.0)
   - Managed by `makefiles/hirestxt-lib.mk`
   - Downloads from: https://github.com/RichStephens/hirestxt-mod/releases
   - Library is cached in `_cache/hirestxt-lib/0.5.0/`
   - Provides high-resolution text display support for CoCo graphics mode
   - Automatically linked with CMOC compiler via `-lhirestxt` flag

### Build System Adjustments

1. **Removed `-vm` Flag from cc65 Linker**
   - Modified `makefiles/toolchains/cc65.mk`
   - Reason: Verbose map flag was interfering with proper library linking

2. **Excluded Test File**
   - Renamed `src/main_og.c` to `src/main_og.c.bak`
   - Reason: Test file had FujiNet dependencies that conflicted with build

## Toolchain Requirements

### macOS Installation

```bash
# cc65 (for Apple II and Atari)
brew install cc65

# CMOC (for CoCo)
brew install cmoc

# decb (for CoCo disk images)
brew install decb

# acx and ac (for Apple II disk images)
brew install acx
```

### Verify Installation

```bash
cl65 --version          # cc65
cmoc --version          # CMOC
decb --version          # decb
acx --version           # acx
```

## Known Issues

### FujiNet Library Linking

The FujiNet library v4.7.9 pre-built binaries may have unresolved symbol references (`c_sp`) with certain cc65 versions. This is a known compatibility issue between the FujiNet library build and the installed cc65 version.

**Resolution**: Install the latest cc65 version:

```bash
brew upgrade cc65
```

If issues persist, consider:
1. Building FujiNet library from source
2. Using a different FujiNet library version
3. Building without FujiNet library support

## Extension Points

### Adding New Platforms

1. Create `src/newplatform/` directory for platform-specific code
2. Create `makefiles/platforms/newplatform.mk` with:
   - `EXECUTABLE` - Output format
   - `DISK` - Disk image format (if applicable)
   - Include appropriate toolchain (e.g., `cc65.mk`)
3. Add platform to `PLATFORMS` variable in Makefile
4. Add `EXTRA_INCLUDE_NEWPLATFORM` if needed

### Adding Platform-Specific Flags

```makefile
CFLAGS_EXTRA_NEWPLATFORM = -O2 --special-flag
LDFLAGS_EXTRA_NEWPLATFORM = --custom-linker-flag
```

### Post-Build Customization

```makefile
newplatform/r2r:: newplatform/custom-step
	@echo "Custom build step for newplatform"
```

## Makefile Variables Reference

| Variable | Purpose | Example |
|----------|---------|---------|
| `PRODUCT` | Output binary name | `hello` |
| `PLATFORMS` | Target platforms | `apple2 atari coco` |
| `SRC_DIRS` | Source directories | `src src/common src/%PLATFORM%` |
| `EXTRA_INCLUDE` | Global include paths | `src/include src/common` |
| `EXTRA_INCLUDE_<PLATFORM>` | Platform-specific includes | `EXTRA_INCLUDE_APPLE2 = src/apple2` |
| `FUJINET_LIB` | FujiNet library version | `4.7.9` |
| `PLATFORM_COMBOS` | Extra platform directories | `c64+=commodore` |

## Build System Files

### Core Framework Files (Do Not Customize)

- `makefiles/toplevel-rules.mk` - Top-level build orchestration
- `makefiles/common.mk` - Shared compilation rules
- `makefiles/tc-common.mk` - Toolchain abstraction
- `makefiles/fnlib.py` - FujiNet library resolver

### Platform Makefiles

- `makefiles/platforms/apple2.mk` - Apple II build rules
- `makefiles/platforms/atari.mk` - Atari build rules
- `makefiles/platforms/coco.mk` - CoCo build rules
- `makefiles/platforms/` - Other platform definitions

### Toolchain Makefiles

- `makefiles/toolchains/cc65.mk` - cc65 compiler rules
- `makefiles/toolchains/cmoc.mk` - CMOC compiler rules
- `makefiles/toolchains/z88dk.mk` - Z88DK compiler rules
- `makefiles/toolchains/` - Other toolchain definitions

### Project Customization

- `Makefile` - **ONLY FILE TO CUSTOMIZE** for project-specific settings

## Troubleshooting

### Build Fails with "Platform not found"

Ensure the platform is listed in `PLATFORMS` variable in the Makefile.

### Include files not found

Check that include directories are properly configured:
- `EXTRA_INCLUDE` for global includes
- `EXTRA_INCLUDE_<PLATFORM>` for platform-specific includes

### FujiNet library not available

Verify `FUJINET_LIB` is set correctly and internet connection is available for download.

### Linker errors with undefined symbols

Ensure all required toolchains are installed and in PATH:
```bash
which cl65 cmoc decb acx
```

## References

- **MekkoGX Framework**: https://github.com/fozzTexx/MekkoGX
- **cc65 Compiler**: https://cc65.github.io/
- **CMOC Compiler**: http://sarrazip.com/cmoc.html
- **FujiNet Library**: https://github.com/FujiNetWIFI/fujinet-lib
