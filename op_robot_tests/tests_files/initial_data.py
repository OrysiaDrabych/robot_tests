# -*- coding: utf-8 -
from datetime import timedelta
from faker import Factory
from faker.providers.company.en_US import Provider as CompanyProviderEnUs
from faker.providers.company.ru_RU import Provider as CompanyProviderRuRu
from munch import munchify
from uuid import uuid4
from tempfile import NamedTemporaryFile
from .local_time import get_now
from op_faker import OP_Provider
import os
import random


fake_en = Factory.create(locale='en_US')
fake_ru = Factory.create(locale='ru_RU')
fake_uk = Factory.create(locale='uk_UA')
fake_uk.add_provider(OP_Provider)
fake = fake_uk

# This workaround fixes an error caused by missing "catch_phrase" class method
# for the "ru_RU" locale in Faker >= 0.7.4
fake_ru.add_provider(CompanyProviderEnUs)
fake_ru.add_provider(CompanyProviderRuRu)


def create_fake_sentence():
    return u"[ТЕСТУВАННЯ] {}".format(fake.sentence(nb_words=10, variable_nb_words=True))


def create_fake_tenderAttempts():
   return fake.random_int(min=1, max=4)


def create_fake_amount():
    return round(random.randint(3000, 999999999))


def create_fake_year():
    return random.randint(1000, 9999)


def create_fake_value(value_amount):
    return round(random.uniform(0.5, 0.999) * value_amount, 2)


def create_fake_minimal_step(value_amount):
    return round(random.uniform(0.01, 0.03) * value_amount, 2)


def create_fake_guarantee(value_amount):
    guarantee = round(0.1 * value_amount, 2)
    # Required guarantee deposit must not be greater than 500 000 UAH
    return guarantee if guarantee <= 500000 else 500000


def create_fake_cancellation_reason():
    reasons = [u"Згідно рішення виконавчої дирекції Фонду гарантування вкладів фізичних осіб",
               u"Порушення порядку публікації оголошення"]
    return random.choice(reasons)


def field_with_id(prefix, sentence):
    return u"{}-{}: {}".format(prefix, fake.uuid4()[:8], sentence)


def create_fake_dgfID():
    return fake.dgfID()


def translate_country_en(country):
    if country == u"Україна":
        return "Ukraine"
    else:
        raise Exception(u"Cannot translate country to english: {}".format(country))


def translate_country_ru(country):
    if country == u"Україна":
        return u"Украина"
    else:
        raise Exception(u"Cannot translate country to russian: {}".format(country))


def create_fake_doc():
    content = fake.text()
    suffix = fake.random_element(('.doc', '.docx', '.pdf'))
    prefix = "{}-{}{}".format("d", fake.uuid4()[:8], fake_en.word())
    tf = NamedTemporaryFile(delete=False, suffix=suffix, prefix=prefix)
    tf.write(content)
    tf.close()
    return tf.name, os.path.basename(tf.name), content


def create_fake_image():
    # TODO: Move this code (as well as other "fake" stuff in this file)
    # into op_faker
    # Also, this doesn't create any images for now; instead,
    # pre-generated ones are used.
    image_format = fake.random_element(('jpg', 'png'))
    return os.path.abspath(os.path.join(os.path.dirname(__file__),
                                        'op_faker',
                                        'illustration.' + image_format))


def create_fake_url():
    """
    Generate fake valid URL for VDR and technicalSpecifications
    randomize size, font and background color for image.
    Example: https://dummyimage.com/700x400/964f96/363636
    """
    base = 'https://dummyimage.com'
    background_color = ''.join([random.choice('0123456789ABCDEF') for _ in range(6)])
    font_color = ''.join([random.choice('0123456789ABCDEF') for _ in range(6)])
    size_x =  random.randint(10, 1000)
    size_y =  random.randint(10, 1000)
    return '{0}/{1}x{2}/{3}/{4}.png'.format(base, size_x, size_y, background_color, font_color)


def test_tender_data(params, periods=("enquiry", "tender")):
    now = get_now()
    value_amount = create_fake_amount()  # max value equals to budget of Ukraine in hryvnias

    data = {
        "mode": "test",
        "submissionMethodDetails": "quick",
        "description": fake.description(),
        "description_en": fake_en.sentence(nb_words=10, variable_nb_words=True),
        "description_ru": fake_ru.sentence(nb_words=10, variable_nb_words=True),
        "title": fake.title(),
        "title_en": fake_en.catch_phrase(),
        "title_ru": fake_ru.catch_phrase(),
        "procuringEntity": fake.procuringEntity(),
        "value": {
            "amount": value_amount,
            "currency": u"UAH",
            "valueAddedTaxIncluded": True
        },
        "guarantee": {
            "amount": create_fake_guarantee(value_amount),
            "currency": u"UAH"
        },
        "minimalStep": {
            "amount": create_fake_minimal_step(value_amount),
            "currency": u"UAH"
        },
        "items": [],
    }

    accelerator = params['intervals']['accelerator']
    # data['procurementMethodDetails'] = 'quick, ' \
    #     'accelerator={}'.format(accelerator)

    data["procuringEntity"]["kind"] = "other"

    scheme_group = fake.scheme_other()[:3]
    for i in range(params['number_of_items']):
        new_item = test_item_data(scheme_group)
        data['items'].append(new_item)

    if data.get("mode") == "test":
        data["title"] = u"[ТЕСТУВАННЯ] {}".format(data["title"])
        data["title_en"] = u"[TESTING] {}".format(data["title_en"])
        data["title_ru"] = u"[ТЕСТИРОВАНИЕ] {}".format(data["title_ru"])

    period_dict = {}
    inc_dt = now
    for period_name in periods:
        period_dict[period_name + "Period"] = {}
        for i, j in zip(range(2), ("start", "end")):
            inc_dt += timedelta(days=params['intervals'][period_name][i])
            period_dict[period_name + "Period"][j + "Date"] = inc_dt.isoformat()
    data.update(period_dict)

    return munchify(data)


def test_asset_data(params):
    cpv_group = fake.scheme_other()
    classification= test_item_data(cpv_group)
    value= test_bid_value(1000000,10)
    test_asset_data = {
        "title": u"[ТЕСТУВАННЯ] {}".format(fake.title()),
        "assetType": "basic",
        "mode": "test",
        "items": [],
    }
    test_asset_data.update(classification)
    test_asset_data.update(value)

    if params['asset_type'] == "claimRights":
        scheme_group = fake.scheme_other()[:3]
        test_asset_data['debt']= {
            "agreementNumber": random.randint(10, 100), 
            "value": {
                "currency": "UAH", 
                "amount": create_fake_amount()
            }, 
            "debtCurrencyValue": {
                "currency": "USD", 
                "amount": create_fake_amount()
            }, 
            "dateSigned": (get_now() + timedelta(days=-2)).strftime('%Y-%m-%d'), 
            "debtorType": "legalPerson"
        }
        for i in range(params['number_of_items']):
            new_item = test_item_data(scheme_group)
            test_asset_data['items'].append(new_item)
        for index in range(params['number_of_items']):
            del test_asset_data['items'][index]['assetCustodian']
        test_asset_data["assetType"] = "claimRights"
    else:
        del test_asset_data["items"]
    test_asset_data["quantity"] = round(random.uniform(1, 10), 3)
    return munchify(test_asset_data)


def test_lot_data(assets_id):
    cpv_group = fake.scheme_other()
    classification= test_item_data(cpv_group)
    test_lot_data = {
        "title": u"[ТЕСТУВАННЯ] {}".format(fake.title()), 
        "lotType": "basic",
        "mode": "test"
    }
    test_lot_data['lotIdentifier']= fake.dgfID()
    test_lot_data['lotCustodian']= classification['assetCustodian']
    test_lot_data['description']= classification['description']
    test_lot_data['assets']= assets_id
    return munchify(test_lot_data)


def test_question_data():
    return munchify({
        "data": {
            "author": fake.procuringEntity(),
            "description": fake.description(),
            "title": field_with_id("q", fake.title())
        }
    })


def test_related_question(question, relation, obj_id):
    question.data.update({"questionOf": relation, "relatedItem": obj_id})
    return munchify(question)


def test_question_answer_data():
    return munchify({
        "data": {
            "answer": fake.sentence(nb_words=40, variable_nb_words=True)
        }
    })


def test_confirm_data(id):
    return munchify({
        "data": {
            "status": "active",
            "id": id
        }
    })


def test_bid_data():
    bid = munchify({
        "data": {
            "tenderers": [
                fake.procuringEntity()
            ]
        }
    })
    bid.data.tenderers[0].address.countryName_en = translate_country_en(bid.data.tenderers[0].address.countryName)
    bid.data.tenderers[0].address.countryName_ru = translate_country_ru(bid.data.tenderers[0].address.countryName)
    return bid


def test_bid_value(max_value_amount, minimalStep):
    return munchify({
        "value": {
            "currency": "UAH",
            "amount": round(random.uniform(1, 1.05)*(max_value_amount + minimalStep), 2),
            "valueAddedTaxIncluded": True
        }
    })


def test_supplier_data():
    return munchify({
        "data": {
            "suppliers": [
                fake.procuringEntity()
            ],
            "value": {
                "amount": fake.random_int(min=1),
                "currency": "UAH",
                "valueAddedTaxIncluded": True
            },
            "qualified": True
        }
    })


def test_item_data(scheme):
    #using typical functions for dgf other and all other modes besides dgf financial
    #items will be genareted from other CAV-PS group
    data = fake.fake_item(scheme)

    data["description"] = field_with_id("i", data["description"])
    data["description_en"] = field_with_id("i", data["description_en"])
    data["description_ru"] = field_with_id("i", data["description_ru"])
    schema_properties = fake_schema_properties(scheme)
    data.update(schema_properties)
    return munchify(data)


def test_tender_data_dgf_other(params):
    data = test_tender_data(params, [])
    data["dgfDecisionDate"] =  u"2016-11-17"
    data["dgfDecisionID"] = u"219560"
    data["merchandisingObject"] = params['lot_id']
    data["status"] = "draft"
    # data['dgfID'] = fake.dgfID()
    data['tenderAttempts'] =  fake.random_int(min=1, max=4)
    del data["procuringEntity"]
    del data["items"]

    # for i in range(params['number_of_items']):
    #     data['items'].pop()

    url = params['api_host_url']
    if url == 'https://lb.api.ea.openprocurement.org':
        del data['procurementMethodDetails']

    period_dict = {}
    inc_dt = get_now()
    period_dict["auctionPeriod"] = {}
    inc_dt += timedelta(days=params['intervals']['auction'][0])
    period_dict["auctionPeriod"]["startDate"] = inc_dt.isoformat()
    data.update(period_dict)
    del data["mode"]
    data['procurementMethodType'] = 'dgfOtherAssets'
    data["procuringEntity"] = fake.procuringEntity_other()

    # for i in range(params['number_of_items']):
    #     scheme_group_other = fake.scheme_other()[:4]
    #     new_item = test_item_data(scheme_group_other)
    #     data['items'].append(new_item)
    return data


def fake_schema_properties(cav):
    data = {
        "schema_properties" : {
                "code": "04",
                "version": "001",
                "properties": {
                    "year": random.randint(1000, 9999),
                    "floor": random.randint(0, 10),
                    "livingArea": random.randint(0, 100),
                    "landArea": random.randint(0, 100),
                    "kitchenArea": random.randint(0, 30),
                    "totalArea": random.randint(0, 1000),
                    "constructionTechnology": [random.choice([u"monolithicFrame", u"panel", u"insulatedPanel", u"brick", u"other"])]
                    }
                }
            }
    return data


# def fake_schema_properties(cav):
#     data = {
#         "schema_properties" : {
#                 "code": "06",
#                 "version": "002",
#                 "properties": {
#                     "cadastralNumber": "1234567891:12:345:6547",
#                     "area": random.randint(10, 1000),
#                     "ownershipForm": [random.choice([u"state", u"private", u"municipal", u"unknown"])],
#                     "encumbrances": [random.choice([u"arrest", u"collateral", u"restraintsOnAlienation", u"otherEncumbrances", u"noEncumbrances"])],
#                     "jointOwnership": random.choice([True, False]),
#                     "utilitiesAvailability": random.choice([True, False]),
#                     "inUse": random.choice([True, False])
#                     }
#                 }
#             }
#     return data


# def fake_schema_properties(cav):
#     data = {
#         "schema_properties" : {
#                 "code": "341",
#                 "version": "001",
#                 "properties": {
#                     "make": "BMW",
#                     "model": "116i",
#                     "fuelType": [random.choice([u"petrol", u"diesel", u"naturalGas", u"liquefiedPetroleumGas", u"electric", u"hybrid", u"other"])],
#                     "vehicleTransmission": [random.choice([u"manual", u"automatic", u"semiAutomatic", u"other"])],
#                     "productionDate": random.randint(1885, 9999),
#                     "odometer": random.randint(0, 1000),
#                     "engineDisplacement": random.randint(0, 1000),
#                     "vehicleIdentificationNumber": "WA-W0",
#                     "itemCondition": "Справний"
#                     }
#                 }
#             }
#     return data
