# attempt creating a podcast2.0 spec podcast feed
# example feed: https://github.com/Podcastindex-org/podcast-namespace/blob/main/example.xml

# import python modules
from pod2gen import *
from datetime import *
from dateutil import *

from lxml import etree

import inspect

class Recipient(object):
    def __init__(self, name=None, address_type=None, address=None, split=None):
        self.__name=name
        self.__address_type=address_type
        self.__address=address
        self.__split=split

        self.name=name
        self.address_type=address_type
        self.address=address
        self.split=split

    # def rss_entry(self):
    #     PODCAST_NS = "https://podcastindex.org/namespace/1.0"

    #     entry = etree.Element("{%s}valueRecipient" % PODCAST_NS)

    #     entry.attrib["name"] = self.name
    #     entry.attrib["type"] = self.address_type
    #     entry.attrib["address"] = self.address
    #     entry.attrib["split"] = self.split

    #     return entry
    
    @property
    def name(self):
        """This recipient's name.
        
        :type: :obj:`str`
        """

        return self.__name
    
    @name.setter
    def name(self, new_name):
        self.__name = new_name
    
    @property
    def address_type(self):
        """This recipient's type of receiving address
        
        :type: :obj:`str`
        """
        return self.__address_type
    
    @address_type.setter
    def address_type(self, new_type):
        self.__address_type = new_type

    @property
    def address(self):
        """This recipient's address that will receive the payment
        
        :type: :obj:`str`
        """
        return self.__address
    
    @address.setter
    def address(self, new_address):
        self.__address = new_address

    @property
    def split(self):
        """The number of shares of the payment this recipient will receive
        
        :type: :obj:`int`
        """
        return self.__split
    
    @split.setter
    def split(self, new_split):
        if not isinstance(new_split, int):
            raise ValueError("split must be a valid integer")
        
        self.__split = str(new_split)

    def __str__(self):
        return "Recipient(name=%s, address_type=%s, address=%s, split=%r)" % (
            self.name,
            self.address_type,
            self.address,
            self.split
        )
    
    def __repr__(self):
        return self.__str__()
 
class PodcastWithValue(Podcast):
    """Data-oriented class representing the payment layer used for the podcast.
    
    The ValueBlock class represents the podcast:value RSS element.
    """
    # was def __init__(self, type, method, suggested)
    def __init__(self, *args, **kwargs):
        
        self.__protocol_type = None
        self.__method = None
        self.__suggested = None
        self.__recipients = []
        self.__recipient_class = Recipient

        super().__init__(*args, **kwargs)
        
        # populate with keyword arguments
        for attribute, value in kwargs.items():
            if hasattr(self, attribute):
                setattr(self, attribute, value)
            else:
                raise TypeError(
                    "Keyword argument %s (with value %s) doesn't match "
                    "any attribute in ValueBlock." % (attribute, value)
                )
        
    @property
    def protocol_type(self):
        """The service slug of the cryptocurrency or protocol layer
        
        :type: :obj:`str`
        """
        return self.__protocol_type
    
    @protocol_type.setter
    def protocol_type(self, protocol_type):
        if not protocol_type:
            raise ValueError(
                "protocol_type property of Value objects cannot be empty or None"
            )
        
        if not isinstance(protocol_type, str):
            raise TypeError("protocol_type must be a valid string")
        self.__protocol_type = protocol_type

    @property
    def method(self):
        """The transport mechanism that will be used.
        
        :method: :obj:`str`
        """
        return self.__method
    
    @method.setter
    def method(self, method):
        if not method:
            raise ValueError(
                "method property of Value objects cannot be empty or None"
            )
        
        if not isinstance(method, str):
            raise TypeError("method must be a valid string")
        self.__method = method

    @property
    def suggested(self):
        """This is an optional suggestion on how much cryptocurrency to send with each payment
        
        :suggested: :obj:`float` or :obj:`None`
        """
        return self.__suggested
    
    @suggested.setter
    def suggested(self, suggested):
        if not suggested:
            raise ValueError(
                "method property of Value objects cannot be empty or None"
            )

        if not isinstance(suggested, str):
            raise TypeError("method must be a valid string")
        self.__suggested = suggested

    @property
    def recipients(self):
        return self.__recipients
    
    @recipients.setter
    def recipients(self, recipients):
        self.__recipients = list(recipients) if not isinstance(recipients, list) else recipients

    @property
    def recipient_class(self):
        return self.__recipient_class
    
    @recipient_class.setter
    def recipient_class(self, value):
        if not inspect.isclass(value):
            raise ValueError(
                "New recipient_class must NOT be an _instance_ of "
                "the desired class, but rather the class itself. "
                "You can generally achieve this by removing the "
                "parenthesis from the constructor call. For "
                "example, use Recipient, not Recipient()."
            )
        elif issubclass(value, Recipient):
            self.__recipient_class = value
        else:
            raise ValueError(
                "New recipient_class must be Recipient or a descendent"
                " of it (so the API still works)"
            )
            

    def add_recipient(self, new_recipient=None):
        if new_recipient is None:
            new_recipient = self.recipient_class()
        self.recipients.append(new_recipient)
        print(self.recipients)
        return new_recipient

    def _create_rss(self):
        PODCAST_NS = self._nsmap["podcast"]
        rss = super()._create_rss()
        channel = rss.find("channel")
        # TODO: Add condition
        vb = etree.SubElement(channel, '{%s}value' % PODCAST_NS)
        vb.attrib["type"] = self.protocol_type
        vb.attrib["method"] = self.method
        vb.attrib["suggested"] = self.suggested

        if self.recipients:
            for x in self.recipients:
                recipient = etree.SubElement(vb, '{%s}valueRecipient' % PODCAST_NS)
                recipient.attrib["name"] = x.name
                recipient.attrib["type"] = x.address_type
                recipient.attrib["address"] = x.address
                recipient.attrib["split"] = x.split
    
        # return the new etree, now with valueblock
        return rss

# class EpisodeWithValue(Episode):
#     def __init__(self, *args, **kwargs):
#         self.__protocol_type = None
#         self.__method = None
#         self.__suggested = None
#         self.__recipients = []
#         self.__recipient_class = Recipient

#         super().__init__(*args, **kwargs)
        
#         # populate with keyword arguments
#         for attribute, value in kwargs.items():
#             if hasattr(self, attribute):
#                 setattr(self, attribute, value)
#             else:
#                 raise TypeError(
#                     "Keyword argument %s (with value %s) doesn't match "
#                     "any attribute in ValueBlock." % (attribute, value)
#                 )
#     @property
#     def protocol_type(self):
#         """The service slug of the cryptocurrency or protocol layer
        
#         :type: :obj:`str`
#         """
#         return self.__protocol_type
    
#     @protocol_type.setter
#     def protocol_type(self, protocol_type):
#         if not protocol_type:
#             raise ValueError(
#                 "protocol_type property of Value objects cannot be empty or None"
#             )
        
#         if not isinstance(protocol_type, str):
#             raise TypeError("protocol_type must be a valid string")
#         self.__protocol_type = protocol_type

#     @property
#     def method(self):
#         """The transport mechanism that will be used.
        
#         :method: :obj:`str`
#         """
#         return self.__method
    
#     @method.setter
#     def method(self, method):
#         if not method:
#             raise ValueError(
#                 "method property of Value objects cannot be empty or None"
#             )
        
#         if not isinstance(method, str):
#             raise TypeError("method must be a valid string")
#         self.__method = method

#     @property
#     def suggested(self):
#         """This is an optional suggestion on how much cryptocurrency to send with each payment
        
#         :suggested: :obj:`float` or :obj:`None`
#         """
#         return self.__suggested
    
#     @suggested.setter
#     def suggested(self, suggested):
#         if not suggested:
#             raise ValueError(
#                 "method property of Value objects cannot be empty or None"
#             )

#         if not isinstance(suggested, str):
#             raise TypeError("method must be a valid string")
#         self.__suggested = suggested

#     @property
#     def recipients(self):
#         return self.__recipients
    
#     @recipients.setter
#     def recipients(self, recipients):
#         self.__recipients = list(recipients) if not isinstance(recipients, list) else recipients

#     @property
#     def recipient_class(self):
#         return self.__recipient_class
    
#     @recipient_class.setter
#     def recipient_class(self, value):
#         if not inspect.isclass(value):
#             raise ValueError(
#                 "New recipient_class must NOT be an _instance_ of "
#                 "the desired class, but rather the class itself. "
#                 "You can generally achieve this by removing the "
#                 "parenthesis from the constructor call. For "
#                 "example, use Recipient, not Recipient()."
#             )
#         elif issubclass(value, Recipient):
#             self.__recipient_class = value
#         else:
#             raise ValueError(
#                 "New recipient_class must be Recipient or a descendent"
#                 " of it (so the API still works)"
#             )
            

#     def add_recipient(self, new_recipient=None):
#         if new_recipient is None:
#             new_recipient = self.recipient_class()
#         self.recipients.append(new_recipient)
#         print(self.recipients)
#         return new_recipient

#     def rss_entry(self):
#         PODCAST_NS = "https://podcastindex.org/namespace/1.0"
#         #rss = super().rss_entry()
#         #entry = rss.find("item")
#         element = etree.Element("{%s}value" % PODCAST_NS)

#         #vb = etree.SubElement(entry, "{%s}value" % PODCAST_NS)
#         element.attrib["type"] = self.protocol_type
#         element.attrib["method"] = self.method
#         element.attrib["suggested"] = self.suggested

#         if self.recipients:
#             for x in self.recipients:
#                 recipient = etree.SubElement(element, '{%s}valueRecipient' % PODCAST_NS)
#                 recipient.attrib["name"] = x.name
#                 recipient.attrib["type"] = x.address_type
#                 recipient.attrib["address"] = x.address
#                 recipient.attrib["split"] = x.split
    
#         # return the new etree, now with valueblock
#         return element
