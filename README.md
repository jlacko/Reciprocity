# Reciprocity

[Reciprocity failure](https://en.wikipedia.org/wiki/Reciprocity_(photography)), also called Schwarzschild effect, is a well known feature of film photography. For exposure times between 1/1,000 of a second and 1 second applies a simple relationship: exposure value = light intensity × time. This relationship is used by photographers to determine camera settings (aperture and exposure time).

For exposure times longer than 1 second this simple relationship breaks down, and the exposure time measured with a light meter needs to be adjusted upwards (for correct exposure a longer than expected time is necessary). This breakdown of laws of reciprocity is different for various film emulsions, and a number of conversion tables are provided by film manufacturers.

I was not satisfied with the published data - some manufacturers quote only [three data points](http://www.foma.cz/en/fomapan-100) - which I found inadequate.

I have therefore created a simple project, which uses R to estimate a more general function for the film reciprocity failure, display a chart and interpolate a table of adjusted times for exposure values (½ EV steps from one second to one minute). 

The project uses log - log transformation to linearize power law function (formula y = a × x ^ b). I have found this to be the closest estimate of all simple functions, and later discovered it was the the type of function Karl Schwarzschild used all those years ago.
