import sys

import requests
from eliot import start_action, to_file

to_file(sys.stdout)


def check_links(urls):
    with start_action(action_type="check_links", urls=urls):
        for url in urls:
            try:
                with start_action(action_type="download", url=url):
                    response = requests.get(url)
                    response.raise_for_status()
            except Exception as e:
                raise ValueError(str(e))


check_links(['http://www.baidu.com', 'http://www.zhihu.com'])
