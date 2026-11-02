import { useTranslation } from 'react-i18next';
import { useForm, useFieldArray } from 'react-hook-form';
import * as Yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';
import { Form, FormControl, FormField, FormItem } from '@shadecn/components/ui/form';
import { Card, CardContent } from '@shadecn/components/ui/card';
import { Button, MainInput, PageHeader, PageSkeleton } from '@UI/Index';
import contactInfoService from '@services/contactInfo.service';
import useSWR from 'swr';
import Alert from '@UI/Alert/Alert';
import { toast } from 'react-toastify';
import { useNavigate } from 'react-router-dom';
import {
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
    { name: 'instagramLink', label: 'Instagram', icon: IoLogoInstagram, color: 'text-destructive' },
    { name: 'twitterLink', label: 'Twitter', icon: IoLogoTwitter, color: 'text-primary' },
    { name: 'youtubeLink', label: 'YouTube', icon: IoLogoYoutube, color: 'text-destructive' },
    { name: 'linkedinLink', label: 'Linkedin', icon: IoLogoLinkedin, color: 'text-warning' },
    { name: 'tiktokLink', label: 'TikTok', icon: IoLogoTiktok, color: 'text-black' },
    { name: 'website', label: 'Website', icon: IoGlobe, color: 'text-muted-foreground' },
  ];

  if (isLoading) {
    return <PageSkeleton kind="form" />;
  }

  return (
    <div className="space-y-5">
      <PageHeader
        title={t('Contact Information')}
        description={t('contactInfoHint')}
        actions={
          <Alert
            id=""
            buttonComponent={
              <Button variant="dangerOutline">
                <IoTrash className="me-1.5 h-4 w-4" />
                {t('Delete')}
              </Button>
            }
            handler={handleDelete}
          />
        }
      />

      {/* Form Content */}
      <div>
        <div className="mx-auto max-w-4xl">
          <Form {...contactForm}>
            <form onSubmit={contactForm.handleSubmit(onSubmit)}>
              <Card className="overflow-hidden">
                {/* Basic Information Section */}
                <div className="border-b border-border bg-card px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div>
                      <h2 className="text-sm font-semibold text-foreground">
                        {t('Basic Information')}
                      </h2>
                      <p className="text-sm text-muted-foreground">
                        {t('Primary contact details and title')}
                      </p>
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
                <div className="border-b border-border bg-card px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div>
                      <h2 className="text-sm font-semibold text-foreground">
                        {t('Email Addresses')}
                      </h2>
                      <p className="text-sm text-muted-foreground">
                        {t('Manage multiple email addresses')}
                      </p>
                    </div>
                  </div>
                </div>

                <CardContent className="p-6">
                  <div className="space-y-4">
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <h4 className="text-sm font-medium text-foreground">
                        {t('Email Addresses')}
                      </h4>
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
                        <div key={field.id} className="flex items-center gap-2">
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
                            variant="dangerOutline"
                            size="icon"
                            aria-label={t('remove')}
                            title={t('remove')}
                            onClick={() => removeEmail(index)}
                            className="h-10 w-10 shrink-0">
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
                <div className="border-b border-border bg-card px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div>
                      <h2 className="text-sm font-semibold text-foreground">
                        {t('Phone Numbers')}
                      </h2>
                      <p className="text-sm text-muted-foreground">
                        {t('Manage multiple phone numbers')}
                      </p>
                    </div>
                  </div>
                </div>

                <CardContent className="p-6">
                  <div className="space-y-4">
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <h4 className="text-sm font-medium text-foreground">{t('Phone Numbers')}</h4>
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
                        <div key={field.id} className="flex items-center gap-2">
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
                            variant="dangerOutline"
                            size="icon"
                            aria-label={t('remove')}
                            title={t('remove')}
                            onClick={() => removePhone(index)}
                            className="h-10 w-10 shrink-0">
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
                <div className="border-b border-border bg-card px-5 py-3">
                  <div className="flex items-center space-x-3">
                    <div>
                      <h2 className="text-sm font-semibold text-foreground">
                        {t('Social Media Links')}
                      </h2>
                      <p className="text-sm text-muted-foreground">
                        {t('Connect your social media profiles')}
                      </p>
                    </div>
                  </div>
                </div>

                <CardContent className="p-6">
                  <div className="space-y-4">
                    <div className="border-b border-border pb-4">
                      <h3 className="text-sm font-semibold text-foreground">
                        {t('Social Media Links')}
                      </h3>
                      <p className="mt-1 text-sm text-muted-foreground">
                        {t('Connect your social media profiles')}
                      </p>
                    </div>

                    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                      {socialLinks.map((link) => (
                        <div key={link.name} className="space-y-2">
                          <label className="flex items-center gap-2 text-sm font-medium text-foreground">
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
