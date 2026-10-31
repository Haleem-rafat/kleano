import { useTranslation } from 'react-i18next';
import { useForm, useFieldArray } from 'react-hook-form';
import * as Yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';
import { Form, FormControl, FormField, FormItem } from '@shadecn/components/ui/form';
import { Card, CardContent } from '@shadecn/components/ui/card';
import { Button, MainInput } from '@UI/Index';
import contactInfoService from '@services/contactInfo.service';
import useSWR from 'swr';
import Alert from '@UI/Alert/Alert';
import { toast } from 'react-toastify';
import { useNavigate } from 'react-router-dom';
import {
  IoArrowBackCircleOutline,
  IoAdd,
  IoTrash,
  IoMail,
  IoCall,
  IoLogoWhatsapp,
  IoLogoFacebook,
  IoLogoInstagram,
  IoLogoTwitter,
  IoLogoYoutube,
  IoLogoLinkedin,
  IoLogoTiktok,
  IoGlobe,
} from 'react-icons/io5';

const schema = Yup.object().shape({
  contactTitle: Yup.string().required('Contact title is required'),
  emails: Yup.array()
    .of(Yup.string().email('Invalid email format'))
    .min(1, 'At least one email is required'),
  phoneNumbers: Yup.array()
    .of(Yup.string().required('Phone number is required'))
    .min(1, 'At least one phone number is required'),
  whatsAppNumber: Yup.string().required('WhatsApp number is required'),
  facebookLink: Yup.string().url('Invalid URL'),
  instagramLink: Yup.string().url('Invalid URL'),
  twitterLink: Yup.string().url('Invalid URL'),
  youtubeLink: Yup.string().url('Invalid URL'),
  linkedinLink: Yup.string().url('Invalid URL'),
  tiktokLink: Yup.string().url('Invalid URL'),
  website: Yup.string().url('Invalid URL'),
});

const ContactForm = () => {
  const { t } = useTranslation();
  const navigate = useNavigate();

  const fetchContacInfo = async () => {
    await contactInfoService
      .getContactInfo()
      .then((data) => {
        contactForm.reset(data.data);
        return data.data;
      })
      .catch(() => {
        // Handle error silently
      });
  };
  const { data, isLoading, mutate } = useSWR('contact-info', fetchContacInfo);
  const contactForm = useForm({
    resolver: yupResolver(schema),
    defaultValues: {
      contactTitle: '',
      emails: [''],
      phoneNumbers: [''],
      whatsAppNumber: '',
      facebookLink: '',
      instagramLink: '',
      twitterLink: '',
      youtubeLink: '',
      linkedinLink: '',
      tiktokLink: '',
      website: '',
    } as any,
  });

  const {
    fields: emailFields,
    append: appendEmail,
    remove: removeEmail,
  } = useFieldArray({
    control: contactForm.control,
    name: 'emails',
  });

  const {
    fields: phoneFields,
    append: appendPhone,
    remove: removePhone,
  } = useFieldArray({
    control: contactForm.control,
    name: 'phoneNumbers',
  });

  const onSubmit = async (payload) => {
    if (payload._id) {
      delete payload._id;
      await contactInfoService
        .editContactInfo(payload)
        .then(() => {
          toast.success('Contact info updated successfully');
          mutate();
        })
        .catch((e) => {
          toast.error(e.response.localizedMessage['en']);
        });
    } else {
      await contactInfoService
        .createContactInfo(payload)
        .then(() => {
          toast.success('Contact info created successfully');
          mutate();
        })
        .catch((e) => {
          toast.error(e.response.localizedMessage['en']);
        });
    }
  };
  const handleDelete = async () => {
    await contactInfoService
      .deleteContactInfo()
      .then(() => {
        mutate();
        toast.success('Contact info deleted successfully');
      })
      .catch((e) => {
        toast.error(e.response.localizedMessage['en']);
      });
  };

  const socialLinks = [
    { name: 'facebookLink', label: 'Facebook', icon: IoLogoFacebook, color: 'text-primary' },
    { name: 'instagramLink', label: 'Instagram', icon: IoLogoInstagram, color: 'text-pink-600' },
    { name: 'twitterLink', label: 'Twitter', icon: IoLogoTwitter, color: 'text-sky-600' },
    { name: 'youtubeLink', label: 'YouTube', icon: IoLogoYoutube, color: 'text-red-600' },
    { name: 'linkedinLink', label: 'Linkedin', icon: IoLogoLinkedin, color: 'text-yellow-600' },
    { name: 'tiktokLink', label: 'TikTok', icon: IoLogoTiktok, color: 'text-black' },
    { name: 'website', label: 'Website', icon: IoGlobe, color: 'text-slate-600' },
  ];

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-slate-50">
        <div className="text-center">
          <div className="mx-auto mb-4 h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
          <p className="text-slate-600">Loading contact information...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-1">
      {/* Professional Header */}
      <div className="pb-4">
        <div>
          <div className="flex flex-wrap items-center justify-between gap-3">
            <div className="flex items-center space-x-4">
              <button
                type="button"
                onClick={() => navigate(-1)}
                className="rounded-lg p-2 transition-colors hover:bg-slate-100">
                <IoArrowBackCircleOutline className="h-5 w-5 text-slate-600" />
              </button>
              <div>
                <h1 className="text-xl font-semibold tracking-tight text-slate-900">{t('Contact Information')}</h1>
                <p className="mt-1 text-sm text-slate-500">
                  Manage your contact details and social media links
                </p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Alert
                id=""
                buttonComponent={
                  <Button variant="danger" size="sm">
                    <IoTrash className="mr-2 h-4 w-4" />
                    {t('Delete')}
                  </Button>
                }
                handler={handleDelete}
              />
            </div>
          </div>
        </div>
      </div>

      {/* Form Content */}
      <div className="pt-1">
        <div className="mx-auto max-w-[90%]">
          <Form {...contactForm}>
            <form onSubmit={contactForm.handleSubmit(onSubmit)}>
              <Card className="overflow-hidden">
                {/* Basic Information Section */}
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoCall className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('Basic Information')}</h2>
                      <p className="text-sm text-slate-500">{t('Primary contact details and title')}</p>
                    </div>
                  </div>
                </div>

                <CardContent className="p-6">
                  <div className="space-y-6">
                    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                      <FormField
                        control={contactForm.control}
                        name="contactTitle"
                        render={({ field }) => (
                          <FormItem>
                            <FormControl>
                              <MainInput
                                label="Contact Title"
                                placeholder="Enter contact title"
                                type="text"
                                field={field}
                              />
                            </FormControl>
                          </FormItem>
                        )}
                      />
                      <FormField
                        control={contactForm.control}
                        name="whatsAppNumber"
                        render={({ field }) => (
                          <FormItem>
                            <FormControl>
                              <MainInput
                                label="WhatsApp Number"
                                placeholder="Enter WhatsApp number"
                                type="tel"
                                field={field}
                              />
                            </FormControl>
                          </FormItem>
                        )}
                      />
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* Email Addresses Section */}
              <Card className="mt-6 overflow-hidden">
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoMail className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('Email Addresses')}</h2>
                      <p className="text-sm text-slate-500">{t('Manage multiple email addresses')}</p>
                    </div>
                  </div>
                </div>

                <CardContent className="p-6">
                  <div className="space-y-4">
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <h4 className="text-sm font-medium text-slate-700">{t('Email Addresses')}</h4>
                      <Button
                        type="button"
                        variant="secondary"
                        size="sm"
                        onClick={() => appendEmail('')}
                        className="flex items-center gap-2">
                        <IoAdd className="h-4 w-4" />
                        {t('Add Email')}
                      </Button>
                    </div>

                    <div className="space-y-3">
                      {emailFields.map((field, index) => (
                        <div
                          key={field.id}
                          className="flex items-center gap-3 rounded-lg border border-slate-200 bg-slate-50 p-4">
                          <div className="flex-1">
                            <FormField
                              control={contactForm.control}
                              name={`emails.${index}`}
                              render={({ field }) => (
                                <FormItem>
                                  <FormControl>
                                    <MainInput
                                      placeholder="Enter email address"
                                      type="email"
                                      field={field}
                                    />
                                  </FormControl>
                                </FormItem>
                              )}
                            />
                          </div>
                          <Button
                            type="button"
                            variant="danger"
                            size="sm"
                            onClick={() => removeEmail(index)}
                            className="shrink-0">
                            <IoTrash className="h-4 w-4" />
                          </Button>
                        </div>
                      ))}
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* Phone Numbers Section */}
              <Card className="mt-6 overflow-hidden">
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoCall className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('Phone Numbers')}</h2>
                      <p className="text-sm text-slate-500">{t('Manage multiple phone numbers')}</p>
                    </div>
                  </div>
                </div>

                <CardContent className="p-6">
                  <div className="space-y-4">
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <h4 className="text-sm font-medium text-slate-700">{t('Phone Numbers')}</h4>
                      <Button
                        type="button"
                        variant="secondary"
                        size="sm"
                        onClick={() => appendPhone('')}
                        className="flex items-center gap-2">
                        <IoAdd className="h-4 w-4" />
                        {t('Add Phone')}
                      </Button>
                    </div>

                    <div className="space-y-3">
                      {phoneFields.map((field, index) => (
                        <div
                          key={field.id}
                          className="flex items-center gap-3 rounded-lg border border-slate-200 bg-slate-50 p-4">
                          <div className="flex-1">
                            <FormField
                              control={contactForm.control}
                              name={`phoneNumbers.${index}`}
                              render={({ field }) => (
                                <FormItem>
                                  <FormControl>
                                    <MainInput
                                      placeholder="Enter phone number"
                                      type="tel"
                                      field={field}
                                    />
                                  </FormControl>
                                </FormItem>
                              )}
                            />
                          </div>
                          <Button
                            type="button"
                            variant="danger"
                            size="sm"
                            onClick={() => removePhone(index)}
                            className="shrink-0">
                            <IoTrash className="h-4 w-4" />
                          </Button>
                        </div>
                      ))}
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* Social Media Links Section */}
              <Card className="mt-6 overflow-hidden">
                <div className="border-b border-slate-100 bg-white px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-brandTint">
                      <IoLogoWhatsapp className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <h2 className="text-sm font-semibold text-slate-900">{t('Social Media Links')}</h2>
                      <p className="text-sm text-slate-500">{t('Connect your social media profiles')}</p>
                    </div>
                  </div>
                </div>

                <CardContent className="p-6">
                  <div className="space-y-4">
                    <div className="border-b border-slate-200 pb-4">
                      <h3 className="text-sm font-semibold text-slate-900">{t('Social Media Links')}</h3>
                      <p className="mt-1 text-sm text-slate-500">
                        {t('Connect your social media profiles')}
                      </p>
                    </div>

                    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                      {socialLinks.map((link) => (
                        <div key={link.name} className="space-y-2">
                          <label className="flex items-center gap-2 text-sm font-medium text-slate-700">
                            <link.icon className={`h-4 w-4 ${link.color}`} />
                            {link.label}
                          </label>
                          <FormField
                            control={contactForm.control}
                            name={link.name as any}
                            render={({ field }) => (
                              <FormItem>
                                <FormControl>
                                  <MainInput
                                    placeholder={`Enter ${link.label} URL`}
                                    type="url"
                                    field={field}
                                  />
                                </FormControl>
                              </FormItem>
                            )}
                          />
                        </div>
                      ))}
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* Form Actions */}
              <div className="mt-6 flex items-center justify-end pt-6">
                <div className="flex items-center gap-3">
                  <Button type="button" variant="secondary" onClick={() => navigate(-1)}>
                    {t('Cancel')}
                  </Button>
                  <Button type="submit" className="bg-primary text-white hover:bg-primary">
                    {(data as any)?._id ? 'Update Contact Info' : 'Create Contact Info'}
                  </Button>
                </div>
              </div>
            </form>
          </Form>
        </div>
      </div>
    </div>
  );
};

export default ContactForm;
