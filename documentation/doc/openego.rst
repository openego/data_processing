====================
Open_eGo the project
====================


Open Electricity Grid Optimization
==================================

The project open_eGo aims to develop a transparent, inter-grid-level operating
grid planning tool to investigate economic viable grid expansion scenarios
considering alternative flexibility options such as storages or redispatch.

Uniform grid planning is required for a successful energy transition. This
involves the management of the German electricity grid with more than 800
different network operators and the resulting wide range of interests that
sometimes stand at odds with the national economic objectives of the energy
transition. However, there is currently no suitable grid planning tool that
is able to consider optimum national economic use of the various flexibility
options at the different levels. The current challenges of planning for grid
expansion associated with the energy transition are answered by open_eGo.

In energy system analysis, models and input data are often handled restrictively.
Such a lack of transparency impedes reproducibility and consequently also a
proper interpretation of the results. Thus, in open_eGo we publish all our code
on github under the Affero General Public License Version 3.
The data we use as input, but also all our results will be published on the
OpenEnergy Platform, in most cases under an Open Database License Version 1.

For the open_eGo project several python packages are developt which are feeded by
the input data of the data processing.

ego.io
******
SQLAlchemy Interface to the OpenEnergy database (oedb).OEDB table ORM objects are
defined here and small helpers for io tasks are contained. `Learn more here.  <https://github.com/openego/ego.io>`_


Ding0
*****
The DIstribution Network GeneratOr (Ding0) is a tool to generate synthetic
medium and low voltage power distribution grids based on open (or at least
accessible) data. `Learn more here.  <http://dingo.readthedocs.io/en/dev/>`_


eDisGo
******
The python package eDisGo provides a toolbox for analysis and optimization
of distribution grids. `Learn more here.  <http://edisgo.readthedocs.io/en/dev/index.html>`_

eTraGo
******
The python package eTraGo provides a toolbox for Optimization of flexibility
options for transmission grids based on PyPSA. `Learn more here.  <http://etrago.readthedocs.io/en/latest/index.html>`_


eGo
***

The python package eGo is a toolbox and application which connects and integrates
the tools eTraGo and eDisGo in order to calcualte  the overall economic optimum.
`Learn more here.  <http://openego.readthedocs.io/en/dev/welcome.html>`_



.. only:: html

    .. raw:: html

            <p>The text on this website is published under <a href="https://creativecommons.org/licenses/by/4.0/">CC-BY 4.0</a>.</p>
            <p><a href="http://www.bmwi.de/Navigation/EN/Home/home.html"><img src="https://i0.wp.com/reiner-lemoine-institut.de/wp-content/uploads/2016/07/BMWi_Logo_Englisch_KLEIN.jpg" alt="Supported by BMWi" /></a></p>
