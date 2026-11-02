import { EAPI } from '@constants/endpoints';
import { IPromoCodeList, IPromoCodeParams } from '@servicesTypes/promoCod.types';
import i18n from '@app/locales/i18n';
import { EFormFieldType } from '@constants/enums';
import * as Yup from 'yup';
import api from '..';
import { IFormField } from '../api-types';

class promoCodeService {
  public async getAllPromoCode(params?: IPromoCodeParams): Promise<IPromoCodeList> {
    const { data } = await api.get(EAPI.PROMO_CODE, { params });
    return data;
  }

  public async addPromoCodeAllUser(body) {
    const { data } = await api.post(EAPI.PROMO_CODE_ALL_USERS, body);
    return data;
  }
  public async addPromoCodeAllsegment(body) {
    const { data } = await api.post(EAPI.PROMO_CODE_SEGMENT, body);
    return data;
  }

  public async addPromoCodeAllNewComers(body) {
    const { data } = await api.post(EAPI.PROMO_CODE_NEW_COMERS, body);
    return data;
  }
  public async addPromoCodeAggregator(body): Promise<IPromoCodeList> {
    const { data } = await api.post(EAPI.PROMO_CODE_AGGREGATOR, body);
    return data;
  }

  public async addPromoCodeOffline(body): Promise<IPromoCodeList> {
    const { data } = await api.post(EAPI.PROMO_CODE_OFFLINE, body);
    return data;
  }

  public async addPromoCodeB2B(body): Promise<IPromoCodeList> {
    const { data } = await api.post(EAPI.PROMO_CODE_B2B, body);
    return data;
  }
  public async editPromoCodeName(code, id) {
    const { data } = await api.patch(EAPI.EDIT_CODE_NAME.replace(':id', id), { code });
    return data;
  }

  public async editPromoCodeStatus(status: 'activate' | 'disable', id: string) {
    const { data } = await api.post(EAPI.EDIT_CODE_NAME.replace(':id', id) + `/${status}`);
    return data;
  }

  /* API SCHEMAS */
  public addPromoCodeSchema = Yup.object().shape({
    SelectTypeOfPromo: Yup.object()
      .shape({
        label: Yup.string(),
        value: Yup.string(),
      })
      .required('Required field'),
    usesType: Yup.object()
      .shape({
        label: Yup.string(),
        value: Yup.string(),
      })
      .required('Required field'),
    code: Yup.string().min(1).max(30).required('Required field').trim(),
    numberOfUses: Yup.number().min(1).required('Required field'),
    discountPercentage: Yup.number().min(1).max(100).notRequired(),
    discountFixedNumber: Yup.number().min(1).notRequired(),
    isPercentage: Yup.boolean().notRequired().optional(),
    duration: Yup.number().min(1).notRequired(),
    segment: Yup.object()
      .shape({
        label: Yup.string(),
        value: Yup.string(),
      })
      .when('SelectTypeOfPromo', {
        is: 'segment',
        then: () =>
          Yup.object()
            .shape({
              label: Yup.string(),
              value: Yup.string(),
            })
            .required('Required field'),
        otherwise: () =>
          Yup.object()
            .shape({
              label: Yup.string(),
              value: Yup.string(),
            })
            .notRequired()
            .nullable()
            .optional(),
      }),

    durationName: Yup.object()
      .shape({
        label: Yup.string(),
        value: Yup.string(),
      })
      .when('SelectTypeOfPromo', {
        is: 'newComers',
        then: () =>
          Yup.object()
            .shape({
              label: Yup.string(),
              value: Yup.string(),
            })
            .required('Required field'),
        otherwise: () =>
          Yup.object()
            .shape({
              label: Yup.string(),
              value: Yup.string(),
            })
            .notRequired()
            .nullable()
            .optional(),
      }),

    durationNumber: Yup.number().when('SelectTypeOfPromo', {
      is: 'newComers',
      then: () => Yup.number().required('Required field'),
      otherwise: () => Yup.number().notRequired().nullable().optional(),
    }),

    expressionLeftSide: Yup.object()
      .shape({
        label: Yup.string(),
        value: Yup.string(),
      })
      .when('SelectTypeOfPromo', {
        is: 'aggregator',
        then: () =>
          Yup.object()
            .shape({
              label: Yup.string(),
              value: Yup.string(),
            })
            .required('Required field'),
        otherwise: () =>
          Yup.object()
            .shape({
              label: Yup.string(),
              value: Yup.string(),
            })
            .notRequired()
            .nullable()
            .optional(),
      }),

    operator: Yup.object()
      .shape({
        label: Yup.string(),
        value: Yup.string(),
      })
      .when('SelectTypeOfPromo', {
        is: 'aggregator',
        then: () =>
          Yup.object()
            .shape({
              label: Yup.string(),
              value: Yup.string(),
            })
            .required('Required field'),
        otherwise: () =>
          Yup.object()
            .shape({
              label: Yup.string(),
              value: Yup.string(),
            })
            .notRequired()
            .nullable()
            .optional(),
      }),

    expressionRightSide: Yup.string().when('SelectTypeOfPromo', {
      is: 'aggregator',
      then: () => Yup.string().required('Required field'),
      otherwise: () => Yup.string().notRequired().nullable().optional(),
    }),

    userLimits: Yup.number().notRequired().nullable().optional(),
    business: Yup.string().when('SelectTypeOfPromo', {
      is: 'b2b',
      then: () => Yup.string().required('Required field'),
      otherwise: () => Yup.string().notRequired().nullable().optional(),
    }),
    quantity: Yup.number().when('SelectTypeOfPromo', {
      is: 'b2b',
      then: () => Yup.number().min(1).required('Required field'),
      otherwise: () => Yup.number().notRequired().nullable().optional(),
    }),
  });

  /* API FIELDS */
  public commanPromoCodeFormFields: IFormField[] = [
    {
      name: 'SelectTypeOfPromo', //allUsers segment newComers aggregator offline
      title: i18n.t('selectTypeOfPromoCode'),
      placeholder: i18n.t('selectTypeOfPromoCode'),
      type: EFormFieldType.SELECT,
      options: [
        { label: 'All user', value: 'allUsers' },
        { label: 'Segment', value: 'segment' },
        { label: 'New comers', value: 'newComers' },
        { label: 'Aggregator', value: 'aggregator' },
        { label: 'Offline', value: 'offline' },
        { label: 'B2B', value: 'b2b' },
      ],
    },
    {
      name: 'usesType', //allUsers segment newComers aggregator offline
      title: i18n.t('usesType'),
      placeholder: i18n.t('usesType'),
      type: EFormFieldType.SELECT,
      options: [
        { label: 'PER CODE', value: 'PER_CODE' },
        { label: 'PER USER', value: 'PER_USER' },
      ],
    },
    {
      name: 'code',
      title: i18n.t('promoCodeName'),
      placeholder: i18n.t('promoCodeName'),
      type: EFormFieldType.TEXT,
    },
    {
      name: 'isPercentage',
      title: i18n.t('UsePercentageDiscount'),
      placeholder: i18n.t('UsePercentageDiscount'),
      type: EFormFieldType.RADIO,
    },
    {
      name: 'discountPercentage',
      title: i18n.t('discountPercentage'),
      placeholder: i18n.t('discountPercentage'),
      type: EFormFieldType.NUMBER,
      min: 1,
      max: 100,
    },
    {
      name: 'discountFixedNumber',
      title: i18n.t('discountFixedNumber'),
      placeholder: i18n.t('discountFixedNumber'),
      type: EFormFieldType.NUMBER,
      min: 1,
    },
    {
      name: 'numberOfUses',
      title: i18n.t('numberOfUses'),
      placeholder: i18n.t('numberOfUses'),
      type: EFormFieldType.NUMBER,
    },
  ];

  public alluserPromoCodeFormFields: IFormField[] = [
    {
      name: 'duration',
      title: i18n.t('duration'),
      placeholder: i18n.t('duration'),
      type: EFormFieldType.NUMBER,
    },
  ];

  public segmentPromoCodeFormFields: IFormField[] = [
    {
      name: 'segment',
      title: i18n.t('selectSegments'),
      placeholder: i18n.t('selectSegments'),
      type: EFormFieldType.SELECT,
    },
    {
      name: 'duration',
      title: i18n.t('duration'),
      placeholder: i18n.t('duration'),
      type: EFormFieldType.NUMBER,
    },
  ];

  public newComersPromoCodeFormFields: IFormField[] = [
    {
      name: 'durationName',
      title: i18n.t('selectDurationName'),
      placeholder: i18n.t('selectDurationName'),
      type: EFormFieldType.SELECT,
      options: [
        { label: 'Day', value: 'day' },
        { label: 'Week', value: 'week' },
        { label: 'Month', value: 'month' },
        { label: 'Year', value: 'year' },
      ],
    },
    {
      name: 'durationNumber',
      title: i18n.t('durationNumber'),
      placeholder: i18n.t('durationNumber'),
      type: EFormFieldType.NUMBER,
    },
    {
      name: 'duration',
      title: i18n.t('duration'),
      placeholder: i18n.t('duration'),
      type: EFormFieldType.NUMBER,
    },
  ];

  public aggregatorPromoCodeFormFields: IFormField[] = [
    {
      name: 'expressionLeftSide',
      title: i18n.t('selectExpressionLeftSide'),
      placeholder: i18n.t('selectExpressionLeftSide'),
      type: EFormFieldType.SELECT,
      options: [{ label: 'Orders', value: 'orders' }],
    },
    {
      name: 'operator',
      title: i18n.t('selectOperator'),
      placeholder: i18n.t('selectOperator'),
      type: EFormFieldType.SELECT,
      options: [
        { label: 'Less Than', value: 'lessThan' },
        { label: 'Greater Than', value: 'greaterThan' },
        { label: 'Equals', value: 'equals' },
      ],
    },
    {
      name: 'expressionRightSide',
      title: i18n.t('expressionRightSide'),
      placeholder: i18n.t('expressionRightSide'),
      type: EFormFieldType.NUMBER,
    },
    {
      name: 'duration',
      title: i18n.t('duration'),
      placeholder: i18n.t('duration'),
      type: EFormFieldType.NUMBER,
    },
  ];

  public b2bPromoCodeFormFields: IFormField[] = [
    {
      name: 'business',
      title: 'Business',
      placeholder: 'Enter business name',
      type: EFormFieldType.TEXT,
    },
    {
      name: 'quantity',
      title: 'Quantity',
      placeholder: 'Enter quantity',
      type: EFormFieldType.NUMBER,
      min: 1,
      max: 500,
    },
    {
      name: 'duration',
      title: i18n.t('duration'),
      placeholder: i18n.t('duration'),
      type: EFormFieldType.NUMBER,
    },
  ];
}

export default Object.freeze(new promoCodeService());
