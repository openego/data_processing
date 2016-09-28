import json

def create_metadata_json(name, source, reference_date, date_of_collection,
                         original_file, spatial_resolution, description, column,
                         changes, note, license, instruction_for_proper_use):
    """
    Generate metadata JSON string

    Parameters
    ----------
    name : str
    source : dict
    reference_date : str
    date_of_collection : str
    original_file : str
    spatial_resolution : str
    description : str
    column : list of dict
    changes : dict
    note : str
    license : dict
    instruction_for_proper_use : str

    Returns
    -------
    json : str
    """
    meta_dict = {
        'Name': name,
        'Source': source,
        'Reference date': reference_date,
        'Date of collection': date_of_collection,
        'Original file': original_file,
        'Spatial resolution': spatial_resolution,
        'Description': description,
        'Column': column,
        'Changes': changes,
        'Note': note,
        'License': license,
        'Instruction for proper use': instruction_for_proper_use
    }

    return "'" + json.dumps(meta_dict) + "'"


def submit_comment(conn, json, schema, table):
    """
    Add comment to table
    Parameters
    ----------
    conn : SQLAlchemy connection object
    json : str
        JSON string reflecting comment
    schema : str
        Desired database schema
    table : str
        Desired database table

    Returns
    -------
    None
    """
    prefix_str = "COMMENT ON TABLE {0}.{1} IS ".format(schema, table)

    check_json_str = "SELECT obj_description('{0}.{1}'::regclass)::json".format(
        schema, table)

    conn.execution_options(autocommit=True).execute(prefix_str + json + ";")

    conn.execution_options(autocommit=True).execute(check_json_str)