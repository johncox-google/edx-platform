
class Group(object):
    """
    An id and name for a group of students.  The id should be unique
    within the UserPartition this group appears in.
    """
    # in case we want to add to this class, a version will be handy
    # for deserializing old versions.  (This will be serialized in courses)
    VERSION = 1
    def __init__(self, id, name):
        self.id = id
        self.name = name

    def to_json(self):
        """
        'Serialize' to a json-serializable representation.

        Returns:
            a dictionary with keys for the properties of the group.
        """
        return {"id": self.id,
                "name": self.name,
                "version": Group.VERSION}


    @staticmethod
    def from_json(value):
        """
        Deserialize a Group from a json-like representation.

        Args:
            value: a dictionary with keys for the properties of the group.

        Raises TypeError if the value doesn't have the right keys.
        """
        def check(key):
            if key not in value:
                raise TypeError("Group dict {0} missing value key '{1}'".format(
                    value, key))
        check("id")
        check("name")
        check("version")
        if value["version"] != Group.VERSION:
            raise TypeError("Group dict {0} has unexpected version".format(
                value))

        return Group(value["id"], value["name"])


class UserPartition(object):
    """
    A named way to partition users into groups, primarily intended for running
    experiments.  It is expected that each user will be in at most one group in a
    partition.

    A Partition has an id, name, description, and a list of groups.
    The id is intended to be unique within the context where these are used. (e.g. for
    partitions of users within a course, the ids should be unique per-course)
    """
    VERSION = 1

    def __init__(self, id, name, description, groups):

        self.id = id
        self.name = name
        self.description = description
        self.groups = groups


    def to_json(self):
        """
        'Serialize' to a json-serializable representation.

        Returns:
            a dictionary with keys for the properties of the partition.
        """
        return {"id": self.id,
                "name": self.name,
                "description": self.description,
                "groups": [g.to_json() for g in self.groups],
                "version": UserPartition.VERSION}


    @staticmethod
    def from_json(value):
        """
        Deserialize a Group from a json-like representation.

        Args:
            value: a dictionary with keys for the properties of the group.

        Raises TypeError if the value doesn't have the right keys.
        """
        def check(key):
            if key not in value:
                raise TypeError("UserPartition dict {0} missing value key '{1}'"
                                .format(value, key))
        check("id")
        check("name")
        check("description")
        check("version")
        if value["version"] != UserPartition.VERSION:
            raise TypeError("UserPartition dict {0} has unexpected version"
                            .format(value))

        check("groups")
        groups = [Group.from_json(g) for g in value["groups"]]

        return UserPartition(value["id"],
                                      value["name"],
                                      value["description"],
                                      groups)
