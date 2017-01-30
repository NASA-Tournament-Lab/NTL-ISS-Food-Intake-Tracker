# Deploy Automated Scriptis

## Dependency

- Python 2.7.13

## Installation

Install python 2.7.13 from this [link](https://www.python.org/ftp/python/2.7.13/python-2.7.13.amd64.msi).

Open command line in Windows (Type `cmd` in run).

Install the dependencies packaged:

- pip install requests
- pip install ConfigParser

## Configuration

The python script configuration can be found in the `config.ini`.

Update the base url, username and password of the API server (no change is needed to use the Amazon VM).

Update the file names and folder to match the local system.

## Run as Standlone

Run the following command to execute script:

```
$ python send-files.py -c config.ini
```

If you want to mark as removed all existing food, execute the script like this:

```
$ python send-files.py -c config.ini -f
```

## Schedule windows tasks

Check this [link](http://desktop.arcgis.com/en/arcmap/10.3/analyze/executing-tools/scheduling-a-python-script-to-run-at-prescribed-times.htm) on how to schedule a task.

Follow the wizard and complete the executable with python executable and the arguments with value:

- "C:\PATH_TO_SCRIPT\send-files.py" -c C:\PATH_TO_SCRIPT\config.ini
