# This file is part of harbour-laundry.
# SPDX-FileCopyrightText: 2023 Mirian Margiani
# SPDX-License-Identifier: GPL-3.0-or-later

import os
import json
import datetime as dt
import copy
from pathlib import Path
from typing import Dict, List
from glob import glob

if __name__ != '__main__':
    import pyotherside
    HAVE_SIDE = True
else:
    HAVE_SIDE = False


BASE: Path = None
ITEMS_FILE: Path = Path('items.json')
BATCH_DIR: Path = Path('batches')

ITEMS: Dict = None
SUPPORTED_VERSION = 1

TODAY: dt.date = None
LATEST_BATCH_ID: int = 0


_items_json = {
    'items': [
        'Pants', 'T-Shirts', 'Overalls',
    ],

    'version': SUPPORTED_VERSION,
}


_batch_json = {
    'label': '',

    'items': {
        'Pants': {
            'out': 2,
            'fetched': 1,
            'missing': False,
        }
    },

    'version': SUPPORTED_VERSION,
}

_qml_item = {
    'label': 'Pants',

    'out': 2,
    'fetched': 1,
    'missing': False,

    'batchId': 0,
    'batchLabel': '',
    'batchDate': '2023-05-25',

    'section': '<batchDate>|<batchId>|<batchLabel>'
}


def _init(data_path: str) -> None:
    global BASE
    global ITEMS
    global TODAY

    if not BASE:
        BASE = Path(data_path).resolve()

    try:
        BASE.mkdir(exist_ok=True, parents=True)
    except Exception as e:
        if HAVE_SIDE:
            pyotherside.send('error', f'failed to create data directories at {BASE}: {e}')
        else:
            raise RuntimeError(f'failed to create data directories at {BASE}: {e}')

    if not (BASE / ITEMS_FILE).exists():
        with open(BASE / ITEMS_FILE, 'w') as fd:
            json.dump({'items': [], 'version': SUPPORTED_VERSION}, fd)

    with open(BASE / ITEMS_FILE, 'r') as fd:
        ITEMS = json.load(fd)

    if ITEMS['version'] != SUPPORTED_VERSION:
        if HAVE_SIDE:
            pyotherside.send('error-items-invalid-version')
        else:
            raise ValueError(f'unsupported items file version: {ITEMS["version"]}')

    if not (BASE / BATCH_DIR).is_dir():
        (BASE / BATCH_DIR).mkdir(exist_ok=True, parents=True)

    if not TODAY:
        today = dt.date.today().strftime('%F')
        yesterday = (dt.date.today() - dt.timedelta(days=1)).strftime('%F')

        if dt.datetime.now().hour < 3:
            TODAY = yesterday
        else:
            TODAY = today

    if HAVE_SIDE:
        pyotherside.send('today-batch-date', TODAY)


def _load_batch(batch_date: str, batch_id: int) -> dict:
    batch = BASE / BATCH_DIR / f'{batch_date}_{int(batch_id):03d}.json'

    if not batch.is_file():
        return {}

    with open(batch, 'r') as fd:
        loaded = json.load(fd) or {'version': None}

    if loaded['version'] != SUPPORTED_VERSION:
        return {}

    return loaded


def _parse_batch_name(name: str) -> tuple:
    batch_date, ident = name.split('_')
    ident = ident.split('.')[0]

    try:
        batch_date = dt.datetime.strptime(batch_date, '%Y-%m-%d').strftime('%F')
    except ValueError:
        raise ValueError

    try:
        ident = int(ident)
    except ValueError:
        raise ValueError

    return (batch_date, ident)


def _yield_batch_items(name: str) -> None:
    try:
        batch_date, batch_id = _parse_batch_name(name)
        batch = _load_batch(batch_date, batch_id)
        print(f'loading batch {name}')

        items = []
        found_keys = []

        for k, v in batch['items'].items():
            if v['out'] == 0 and v['fetched'] == 0:
                continue

            item = copy.deepcopy(_qml_item)
            item['label'] = k
            item['out'] = v['out']
            item['fetched'] = v['fetched']
            item['missing'] = v['missing']
            item['batchId'] = batch_id
            item['batchDate'] = batch_date
            item['batchLabel'] = batch['label']
            item['section'] = f'{batch_date}|{batch_id}|{batch["label"]}'
            items.append(item)

            found_keys.append(k)

        if batch_date == TODAY:
            for i in ITEMS['items']:
                if i not in found_keys:
                    item = copy.deepcopy(_qml_item)
                    item['label'] = i
                    item['out'] = 0
                    item['fetched'] = 0
                    item['missing'] = False
                    item['batchId'] = batch_id
                    item['batchDate'] = batch_date
                    item['batchLabel'] = batch['label']
                    item['section'] = f'{batch_date}|{batch_id}|{batch["label"]}'
                    items.append(item)

        # for i in ITEMS['items']:
        #     if i not in found_keys:
        #         item = copy.deepcopy(_qml_item)
        #         item['label'] = i
        #         item['out'] = 0
        #         item['fetched'] = 0
        #         item['missing'] = False
        #         item['batchId'] = batch_id
        #         item['batchDate'] = batch_date
        #         item['batchLabel'] = batch['label']
        #         item['section'] = f'{batch_date}|{batch_id}|{batch["label"]}'
        #         items.append(item)

        yield items
    except ValueError:
        print(f'failed to load batch {name}')


def _get_batch_with_item(data_path: str, batch_date: str, batch_id: int, item: str):
    _init(data_path)

    batch = _load_batch(batch_date, batch_id)

    if not batch:
        batch = copy.deepcopy(_batch_json)
        batch['items'] = {}

    if item not in batch['items']:
        batch['items'][item] = {
            'out': 0,
            'fetched': 0,
            'missing': False,
        }

    return batch


def _save_batch(data_path: str, batch_date: str, batch_id: int, batch: dict) -> None:
    _init(data_path)
    batch_file = BASE / BATCH_DIR / f'{batch_date}_{int(batch_id):03d}.json'

    if not batch['items'] and not batch['label'] and batch_file.is_file():
        batch_file.unlink()
    else:
        with open(batch_file, 'w') as fd:
            json.dump(batch, fd)


def set_out_count(data_path: str, batch_date: str, batch_id: int, item: str, count: int) -> None:
    _init(data_path)
    batch = _get_batch_with_item(data_path, batch_date, batch_id, item)
    batch['items'][item]['out'] = count
    _save_batch(data_path, batch_date, batch_id, batch)


def set_fetched_count(data_path: str, batch_date: str, batch_id: int, item: str, count: int) -> None:
    _init(data_path)
    batch = _get_batch_with_item(data_path, batch_date, batch_id, item)
    batch['items'][item]['fetched'] = count
    _save_batch(data_path, batch_date, batch_id, batch)


def set_missing(data_path: str, batch_date: str, batch_id: int, item: str, missing: bool) -> None:
    _init(data_path)
    batch = _get_batch_with_item(data_path, batch_date, batch_id, item)
    batch['items'][item]['missing'] = missing
    _save_batch(data_path, batch_date, batch_id, batch)


def remove_item(data_path: str, batch_date: str, batch_id: int, item: str) -> None:
    _init(data_path)
    batch = _get_batch_with_item(data_path, batch_date, batch_id, item)
    del batch['items'][item]
    _save_batch(data_path, batch_date, batch_id, batch)

    if batch_date == TODAY and item in ITEMS['items']:
        ITEMS['items'].remove(item)

        if HAVE_SIDE:
            pyotherside.send('default-items', ITEMS['items'])

        with open(BASE / ITEMS_FILE, 'w') as fd:
            json.dump(ITEMS, fd)


def rename_item(data_path: str, batch_date: str, batch_id: int, item: str, newName: str) -> None:
    if item == newName:
        return

    _init(data_path)
    batch = _get_batch_with_item(data_path, batch_date, batch_id, item)
    old = copy.deepcopy(batch['items'][item])
    del batch['items'][item]
    batch['items'][newName] = old
    _save_batch(data_path, batch_date, batch_id, batch)

    if batch_date == TODAY and item in ITEMS['items']:
        ITEMS['items'].remove(item)
        ITEMS['items'].append(newName)

        if HAVE_SIDE:
            pyotherside.send('default-items', ITEMS['items'])

        with open(BASE / ITEMS_FILE, 'w') as fd:
            json.dump(ITEMS, fd)


def add_item(data_path: str, label: str) -> None:
    global ITEMS
    _init(data_path)

    if label in ITEMS['items']:
        return

    ITEMS['items'].append(label)

    with open(BASE / ITEMS_FILE, 'w') as fd:
        json.dump(ITEMS, fd)

    # add to current/latest batch

    back = Path.cwd()
    os.chdir(BASE / BATCH_DIR)
    todays_batches = sorted(list(glob(f'{TODAY}_???.json', recursive=False)), reverse=True)

    if HAVE_SIDE:
        pyotherside.send('info', f'=> {todays_batches}')

    if todays_batches:
        _, batch_id = _parse_batch_name(todays_batches[-1])
    elif LATEST_BATCH_ID > 0:
        batch_id = LATEST_BATCH_ID

    if batch_id > 0:
        item = copy.deepcopy(_qml_item)
        item['label'] = label
        item['out'] = 0
        item['fetched'] = 0
        item['missing'] = False
        item['batchId'] = batch_id
        item['batchDate'] = TODAY
        item['batchLabel'] = ''
        item['section'] = f'{TODAY}|{batch_id}|'

        if HAVE_SIDE:
            pyotherside.send('batch-items', [item])
        else:
            yield [item]
    elif HAVE_SIDE:
        pyotherside.send('info', f'nothing to add for {label}: {batch_id}, {LATEST_BATCH_ID}, {TODAY}, {todays_batches}')

    os.chdir(back)


def get_new_batch(data_path) -> None:
    global LATEST_BATCH_ID
    _init(data_path)

    back = Path.cwd()
    os.chdir(BASE / BATCH_DIR)
    todays_batches = sorted(list(glob(f'{TODAY}_???.json', recursive=False)), reverse=True)

    if todays_batches:
        _, batch_id = _parse_batch_name(todays_batches[-1])
        batch_id += 1
    else:
        batch_id = 1

    batch_id = max(batch_id, LATEST_BATCH_ID + 1)
    LATEST_BATCH_ID = batch_id

    items = []

    for i in ITEMS['items']:
        item = copy.deepcopy(_qml_item)
        item['label'] = i
        item['out'] = 0
        item['fetched'] = 0
        item['missing'] = False
        item['batchId'] = batch_id
        item['batchDate'] = TODAY
        item['batchLabel'] = ''
        item['section'] = f'{TODAY}|{batch_id}|'
        items.append(item)

    if HAVE_SIDE:
        pyotherside.send('batch-items', items)
    else:
        yield items

    os.chdir(back)


def get_default_items(data_path) -> List[str]:
    _init(data_path)

    if HAVE_SIDE:
        pyotherside.send('default-items', ITEMS['items'])
    else:
        yield ITEMS['items']


def get_items(data_path) -> None:
    _init(data_path)

    back = Path.cwd()
    os.chdir(BASE / BATCH_DIR)

    todays_batches = sorted(list(glob(f'{TODAY}_???.json', recursive=False)), reverse=True)

    for i in todays_batches:
        for i in _yield_batch_items(i):
            if HAVE_SIDE:
                pyotherside.send('batch-items', i)
            else:
                yield i

    pyotherside.send('default-items', ITEMS['items'])

    for i in glob('????-??-??_???.json', recursive=False):
        if i in todays_batches:
            continue

        for i in _yield_batch_items(i):
            if HAVE_SIDE:
                pyotherside.send('batch-items', i)
            else:
                yield i

    os.chdir(back)


if __name__ == '__main__':
    path = './test'

    print(list(get_items(path)))
