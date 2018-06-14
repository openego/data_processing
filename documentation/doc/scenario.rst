==================
Scenario framework
==================




open_eGo Scenarios
------------------

Three scenarios were defined and used for the intended power flow simulations.
Apart from one status quo scenario representing the German electrical energy
system in 2015, two future scenarios were defined employing exogenous assumptions.
For Germany, the installed generation capacities of the status quo scenario
were taken from the power plant list of the Open Power System Data project
[opsd-conv]_, [opsd-res]_ (State: 01-01-2016).  Whereas the 2035 scenario is
based on publicly available information and methods of the
*Netzentwicklungsplan (NEP) Strom 2025, erster Entwurf* [NEP2015]_ .
Out of several NEP scenarios, the so-called "B1-2035" was chosen;
it is characterized by a high renewable energy expansion and an increased share
of natural gas [NEP2015]_. The third scenario pictures a future electrical
energy system powered to 100% from renewable energy and is mainly based on the
*100% RES* scenario of the *e-Highway2050 - Modular Development Plan
of the Pan-European Transmission System 2050* [ehighway2050]_.
In order to build a 100% energy system in Germany 13\,GW of gas fired power
plants were removed (see: [christ2017]_ and  [FlEnS]_).

Table Characterization of scenarios by key parameters shows the scenario specifications and 
significant characteristics of all three scenarios.


.. csv-table:: Characterization of scenarios by key parameters
   :file: scenario/tabel_Characterization_of_scenarios_by_key_parameters.csv
   :delim: ,
   :header-rows: 1
   :widths: 6, 1, 1, 1
   :stub-columns: 0
   :alt: Statistic and report values (See: BMWi 2017, sheet 20 year 2014 [BMWi]_, NEP 2025 [NEP2015], own calculation for eGo 100%.


Table *Installed generation capacities in GW for Germany and marginal costs for
conventional generation in 2014€/MWh , divided by scenario and technology/fuel*
displays the resulting installed electrical capacities in Germany and marginal
cost assumptions for each scenario divided by the different technologies and fuels.



.. csv-table::Installed generation capacities in GW for Germany and marginal costs for conventional generation in 2014€/MWh , divided by scenario and technology/fuel.
  :file: scenario/tabel_Characterization_of_scenarios_by_key_parameters.csv
  :delim: ,
  :header-rows: 1
  :widths: 6, 1, 1, 1
  :stub-columns: 0




.. toctree::
  :maxdepth: 1
  :titlesonly:

  open_eGo Scenario definition <scenario/ego_scenarios>


Methodology
----------

.. toctree::
  :maxdepth: 1
  :titlesonly:

  Methodology <scenario/methodology>




References
----------

.. [NEP2015] Übertragungsnetzbetreiber Deutschland, Netzentwicklungsplan
    Strom 2025, Version 2015, 1. Entwurf, 2015. https://www.netzentwicklungsplan.de/sites/default/files/paragraphs-files/NEP_2025_1_Entwurf_Teil1_0_0.pdf

.. [coastdat-2] coastDat-2 Hindcast model http://www.coastdat.de/data/index.php.en

.. [FlEnS] Bunke, Wolf-Dieter, Martin Söthe, Marion Wingenbach, and Cord Kaldemeyer. 2018.:
    *“(Fl)ensburg (En)ergy (S)cenarios - open_eGo Scenarios for 2014/2035/2050.”* Open Science Framework. June 13. doi:10.17605/OSF.IO/BPF36.

.. [opsd-conv] `Open Power System Data <http://open-power-system-data.org/>`_. 2016.:
    Data provided by Open Power System Data - Data Package Conventional power plants, version 2016-10-27. Primary data from BNetzA Kraftwerksliste,
    Umweltbundesamt Datenbank Kraftwerke in Deutschland.

.. [opsd-res] `Open Power System Data <http://open-power-system-data.org/>`_. 2017.:
    Data provided by Open Power System Data - Data Package Renewable power plants, early version 2016-02-10. Primary data from BNetzA, BNetzA_PV, TransnetBW, TenneT, Amprion, 50Hertz, Netztransparenz.de, Postleitzahlen Deutschland, Energinet.dk, Energistyrelsen, GeoNames, French Ministery of the Environment, Energy and the Sea, OpenDataSoft, Urzad Regulacji Energetyki (URE)

.. [ehighway2050] e-Highway2050. (2015).:
     e-HIGHWAY 2050 Modular Development Plan of the Pan-European Transmission System 2050 - database per country.  Retrieved from http://www.e-highway2050.eu/fileadmin/documents/Results/e-Highway_database_per_country-08022016.xlsx

.. [christ2017] Christ, M. (2017).:
     Integration sozial-ökologischer Faktoren in die Energiesystemmodellierung am Beispiel von Entwicklungspfaden für den Windenergieausbau in Deutschland (PhD Thesis). Europa-Universität Flensburg.

.. [BMWi]  text ...
