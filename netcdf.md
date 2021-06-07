# Introduction

::: {.frame}
### Who am I?
:::

::: {.frame}
### Background

**Problem**: Earth scientists work with huge, 4+ dimensional datasets (3
spatial dimensions, 1 time dimension, and sometimes even more).

-   Example: Air temperature (longitude, latitude, height, time)

-   Example: Surface pressure from "ensemble" of model simulations
    (longitude, latitude, time, ensemble member)

-   Example: Satellite-retrieved radiation (projection x-coordinate,
    projection y-coordinate, wavenumber)
:::

::: {.frame}
### Background

**Question**: What's the best way to **store** this type of data?

-   Spreadsheets? Not enough dimensions.

-   Matrices? No way to annotate "rows", "columns", etc.

**Answer**: The [NetCDF](https://en.wikipedia.org/wiki/NetCDF) format
(Network Common Data Form) developed by
[UCAR/Unidata](https://www.unidata.ucar.edu/software/netcdf/) (right
down the road!).

-   Description: Annotated N-dimensional matrices (arrays)

-   File extension: `.nc`

There are other similar data formats
([HDF](https://en.wikipedia.org/wiki/Hierarchical_Data_Format),
[GRIB](https://en.wikipedia.org/wiki/GRIB)), and some software can work
seamlessly with different formats... but NetCDF is your new best friend.
:::

::: {.frame}
### Architecture

File formats have [different "version
numbers"](https://www.unidata.ucar.edu/software/netcdf/docs/faq.html#whatisenhanceddatamodel):

-   NetCDF3 (version 3) [retired in
    2008](https://www.unidata.ucar.edu/software/netcdf/docs/RELEASE_NOTES.html#autotoc_md60).
    Unidata is [currently version
    4](https://www.unidata.ucar.edu/software/netcdf/docs/RELEASE_NOTES.html#autotoc_md0).

-   ...however version 3 still widespread (scientists are slow to change
    their ways...too many other things to worry about).

-   Some things in NetCDF4 are impossible in NetCDF3 (multiple unlimited
    dimensions, ...).

-   Weird read/write bugs are sometimes due to version
    incompatibilities.

NetCDF3 still everywhere, so you may need to use it.
:::

::: {.frame}
### Architecture

NetCDF files have the following featuers:

-   Global attributes.

-   Global dimensions.

-   Named variables, each with its own dimensions and attributes.
:::

::: {.frame}
### Architecture

    $ ncdump -h example.nc
    ADD EXAMPLE
:::

::: {.frame}
### Software

There's lots of sotware for working with NetCDF (HDF, GRIB) files.
First, the **command-line** tools:

-   NCO (NetCDF Operators).
:::

::: {.frame}
### Software

Next, the **python** tools:

-   [netCDF4](https://unidata.github.io/netcdf4-python/) (confusingly,
    this works with both Netcdf versions 3 and 4!). netCDF4 is for
    low-level, fast control.

-   [xarray](http://xarray.pydata.org/en/stable/) ("new kid" on the
    block but *extremely* powerful). xarray is for high-level,
    convenient control.

-   Python also has [Iris
    "cubes"](https://scitools.org.uk/iris/docs/v1.13.0/userguide/loading_iris_cubes.html)...
    but this is older, less widespread, falling out of favor ( xarray
    intended as [improvement on
    "cubes"](http://xarray.pydata.org/en/stable/getting-started-guide/faq.html#what-other-netcdf-related-python-libraries-should-i-know-about)
    ).
:::

# Command-line tools

::: {.frame}
### CDO Overview

Many of us know about NCO (NetCDF Operators) and NCL (NCAR Command
Language).

A comparatively recent player is **CDO** (Climate Data Operators).

-   Written in C++ by Max Planck Institut. **Companion** to NCO -- does
    things NCO can't.

-   Install with Anaconda, no sudo necessary:
    `conda install -c conda-forge cdo=1.9.0`.

-   Great documentation, easy-to-remember syntax:
    `cdo -mergetime 2017*.nc out.nc`.

-   **Subcommand chaining**:
    `cdo -add -sqr -selname,u f.nc -sqr -selname,v f.nc KE.nc`.

::: {.center}
`cdo -zonmean -mul -sub -selname,t f.nc -enlarge,f.nc -zonmean -selname,t f.nc \`\
`-sub -selname,v f.nc -enlarge,f.nc -zonmean -selname,v f.nc EHF.nc`.
:::

-   Reads **GRIB** and **NetCDF** files; convert with
    `cdo -f nc f.grb f.nc`.

-   **Streams** input file into output file; does **not** load entire
    file into memory.

-   **Warning**: For many operations, **dimension attributes matter**!
    Verify CDO is reading your file "correctly" with `griddes`,
    `zaxisdes`, `showdate`, ...
:::

::: {.frame}
### CDO Uses

CDO has **hundreds** of subcommands. Here's a quick survey:

-   **Regrid** from one arbitrary grid (e.g. rotated pole, hexagonal
    cells) to another; choose from a suite of algorithms:
    `cdo remapcon,destination_grid.txt in.nc out.nc`.

-   Interpolate to different **vertical levels**:
    `cdo intlevel,1000,900,800,700,600,500,400,300,200 in.nc out.nc`

-   **LLS trends** ignoring missing vals:
    `cdo regres -seldate,1980-01-01T00:00:00,2009-12-31T23:59:59 in.nc out.nc`.

-   Monthly daily and seasonal **statistics**:
    `cdo ymonmean in.nc climate.nc`.

-   **Spatial** operations: `zonmean`; `fldmean`;
    `mulc,101325 -vertmean -genlevelbounds`.

-   Spatial **EOFs**: `cdo eof,10 file.nc evals.nc evecs.nc`.

-   Get **summary statistics** on your file:
    `cdo infon -selname,t -seltimestep,1 file.nc`.
:::

::: {.frame}
### XArray

If you use python, **XArray $\mathbf{\gg}$ netCDF4**. XArray is to
pandas as NetCDF files are to CSV files.

-   Handy objects: Datasets (entire NetCDF file) and DataArrays (single
    variable within NetCDF file).

-   Load Dataset with `d = xr.open_dataset("file.nc", engine="pynio")`.
    For GRIB files, use `xr.open_dataset("file.grb", engine="pynio")`
    (python 3 compatibility coming soon).

-   Operate along dimensions: `d["variable"].mean(dim="longitude")`.

-   Permute dimensions:
    `d.transpose(["time", "latitude", "longitude"])`.

-   Slice dimensions: `d.sel(lat=slice(0,90))`;
    `d.sel(level=850, method="nearest")`;
    `d.sel(time=slice(np.datetime64("2000-01-01"),np.datetime64("2001-01-01")))`.

-   Get underlying `numpy` array: `d["variable"].values`.

-   Save new NetCDF file: `d.to_netcdf("filename.nc")`.

::: {.center}
**`import xarray as xr`**
:::
:::

::: {.frame}
### NCL

There's another tool I didn't mention... the [NCAR Command
Language](https://www.ncl.ucar.edu) (NCL). This is one of my favorites!

-   MATLAB: Everything is an array.

-   Python: Everything is an object (or dictionary, depending on who you
    ask).

-   NCL: Everything is a NetCDF-formatted dataset. If you're a
    geoscientist, this paradigm is pretty awesome.

Sadly, you should avoid using NCL for two reasons...

-   NCL [is being
    deprecated](https://www.ncl.ucar.edu/Document/Pivot_to_Python/september_2019_update.shtml)
    (Unidata developers now focusing on python tools).

-   NCL is very slow...among the slowest tools (see [these simple
    benchmarks](https://github.com/lukelbd/atmos-benchmarks)).
:::

::: {.frame}
### NCL

**Example**: Read XYZT temperature and wind data, save YZT eddy heat
flux.

    $ ncdump -h input.nc
    dimensions:
      time = UNLIMITED ; // (200 currently)
      lev = 60 ;
      lat = 36 ;
      lon = 72 ;
    variables:
      ...
      double v(time, lev, lat, lon) ;
        v:long_name = "meridional wind" ;
        v:units = "m/s" ;
      double t(time, lev, lat, lon) ;
        t:long_name = "temperature" ;
        t:units = "K" ;
:::

::: {.frame}
### NCL

**Example**: Read XYZT temperature and wind data, save YZT eddy heat
flux.

    $ cat fluxes.ncl
    f = addfile("input.nc", "r")
    o = addfile("output.nc", "c")
    t = f->t
    v = f->v
    ehf = dim_avg_n( \
      (t - conform(t, dim_avg_n(t, 2), (/0, 1/))) \
      * (v - conform(v, dim_avg_n(v, 2), (/0, 1/))), \
      3 \
    )
    copy_VarCoords(t(:, :, 0), ehf)
    ehf@long_name = "eddy heat flux"
    ehf@units = "K*m/s"
    o->ehf = ehf
:::

::: {.frame}
### NCL

**Example**: Read XYZT temperature and wind data, save YZT eddy heat
flux.

    $ ncl fluxes.ncl
    $ ncdump -h output.nc
    dimensions:
      time = 200 ;
      lev = 60 ;
      lat = 36 ;
    variables:
      ...
      double ehf(time, lev, lat) ;
        ehf:units = "K*m/s" ;
        ehf:long_name = "eddy heat flux" ;
:::

::: {.frame}
![image](fluxes_60lev_uriah.png){height="1.1\\textheight"}
:::

::: {.frame}
![image](fluxes_60lev_cheyenne4.png){height="1.1\\textheight"}
:::

::: {.frame}
![image](slices_60lev_uriah.png){height="1.1\\textheight"}
:::

::: {.frame}
### Panoply

Many are familiar with **NCView**. Modern alternative is **Panoply**.

-   Freeware released by NASA.

-   Extremely easy to use.

::: {.center}
![image](panoply-demo.pdf){width=".5\\textwidth"}
:::
:::

# Python tools

::: {.frame}
### netCDF4

Now let's get into the python tools.
:::

# Examples

::: {.frame}
### Learning more

-   Use google. Try rephrasing a few times if nothing comes up.

-   Use [stackoverflow](https://stackoverflow.com)! ...but only *ask*
    questions after extensive googling fails.

    Tip: For inline-code examples, use `‘inline code’`. For
    multiline-code examples, use ` “‘ multiline code ’” `.

-   Use slack! Collaboration + cooperation saves everyone time.

    Tip: For inline-code and multiline-code, use backticks -- just like
    stackoverflow.
:::
