# quickglobe

> Spin's the name, and rocking round the globe's the game!

This package was mostly an excuse to sync up some #rstats, GIS, and D3 tricks. It needs a lot more work.

I really wanted to name this package `spintheglobe` in homage to [National Geographic's Really Wild Animals](https://en.wikipedia.org/wiki/Really_Wild_Animals) docs, but the internet has a severe deficit of Spin content. 

## Installation

`quickglobe` is not on CRAN, but uou can install the development version from GitHub via:

``` r
devtools::install_packages_github("daranzolin/quickglobe")
```

## Spinning the Globe

`quickglobe` renders an interactive, 3D globe. There is, however, some data prep: you must convert your country data to the [ISO-3166 format.](https://en.wikipedia.org/wiki/ISO_3166-1_numeric) Here the `countrycode` package is a helpful utility. 

``` r
library(gapminder)
library(countrycode)
library(dplyr)
library(quickglobe)
gm_data <- gapminder %>% 
  filter(year == 2002) 
gm_data$iso_id <- as.character(countrycode(gm_data$country, 'country.name', 'iso3n'))
gm_data$iso_id <- case_when( 
                            nchar(gm_data$iso_id) == 2 ~ paste0("0", gm_data$iso_id),
                            nchar(gm_data$iso_id) == 1 ~ paste0("00", gm_data$iso_id),
                            TRUE ~ gm_data$iso_id
                            )

quickglobe(gm_data, iso_id, gdpPercap)
```
<iframe src="https://giphy.com/embed/3Wvhuqdhm9Vx2aMzPj" width="480" height="474" frameBorder="0" class="giphy-embed" allowFullScreen></iframe><p><a href="https://giphy.com/gifs/rstats-globe-3Wvhuqdhm9Vx2aMzPj">via GIPHY</a></p>

## Future Work
Several features are missing:

* Tooltip
* Legend
* Titles
* More styling options
