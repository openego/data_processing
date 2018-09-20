=============================
Scenario import of renpassG!S
=============================



Installation
============

.. code-block::
              $ virtualenv renpass_importer --clear -p python3.5 
              $ source bin/activate
              $ pip3 install -r requirements.txt



How to import scnario csv files to the oedb
===========================================


.. code-block::
               python3 scenario_import.py "/PATH/status_quo.csv" "/PATH/status_quo_seq.csv" "/PATH/results/scenario_status_quo_-dd-dd_results_complete.csv"  -n "status quo" -c "scenario of sensitivity"




