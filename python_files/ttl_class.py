# attempt creating a podcast2.0 spec podcast feed
# example feed: https://github.com/Podcastindex-org/podcast-namespace/blob/main/example.xml

# import python modules
from pod2gen import *
from datetime import *
from dateutil import *

from lxml import etree

class TtlMixin(object):
    @property
    def ttl(self):
        """Your suggestion for how many minutes podcatchers should wait
        before refreshing the feed.

        ttl stands for "time to live".

        :type: :obj:`int`
        :RSS: ttl
        """
        # By using @property and @ttl.setter, we encapsulate the ttl field
        # so that we can check the value that is assigned to it.
        # If you don't need this, you could just rename self.__ttl to
        # self.ttl and remove those two methods.
        return self.__ttl

    @ttl.setter
    def ttl(self, ttl):
        # Try to convert to int
        try:
            ttl_int = int(ttl)
        except ValueError:
            raise TypeError("ttl expects an integer, got %s" % ttl)
        # Is this negative?
        if ttl_int < 0:
            raise ValueError("Negative ttl values aren't accepted, got %s"
                             % ttl_int)
        # All checks passed
        self.__ttl = ttl_int

    def _create_rss(self):
        PODCAST_NS = self._nsmap["podcast"]
        # Let Podcast generate the lxml etree (adding the standard elements)
        rss = super()._create_rss()
        # We must get the channel element, since we want to add subelements
        # to it.
        channel = rss.find("channel")
        # Only add the ttl element if it has been populated.
        if self.__ttl is not None:
            # First create our new subelement of channel.
            ttl = etree.SubElement(channel, '{%s}ttl' % PODCAST_NS)
            ttl.attrib["type"] = "lightning"
            ttl.attrib["method"] = "keysend"
            ttl.attrib["suggested"] = "0.00000005000"
            # If we were to use another namespace, we would instead do this:
            # ttl = etree.SubElement(channel,
            #                        '{%s}ttl' % self._nsmap['prefix'])

            # Then, fill it with the ttl value
            #ttl.text = str(self.__ttl)
            
            ttl2 = etree.SubElement(ttl, '{%s}valueRecipient' % PODCAST_NS)
            ttl2.attrib["name"] = "podcaster"
            ttl2.attrib["type"] = "node"
            ttl2.attrib["address"] = "aaaaaaaaaaaaaaaaaaaaaaaaaa"
            ttl2.attrib["split"] = "90"


        # Return the new etree, now with ttl
        return rss


# How to use the new mixin
class PodcastWithTtl(TtlMixin, Podcast):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)



# myPodcast = PodcastWithTtl(name="Test", website="http://example.org", explicit=False, description="Testing ttl")

# myPodcast.ttl = 90
# print(myPodcast)
