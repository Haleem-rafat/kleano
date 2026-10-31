import termsService from '@services/terms.service';
import { Textarea } from '@shadecn/components/ui/textarea';
import { Button } from '@UI/Index';
import { useState } from 'react';
import { toast } from 'react-toastify';
import useSWR from 'swr';

const Terms = () => {
  const [termsEn, setTermsEn] = useState<string>('');
  const [termsAr, setTermsAr] = useState<string>('');
  const [isEdit, setIsEdit] = useState(false);
  const [loading, setLoading] = useState(false);
  const fetchTerms = async () => {
    return await termsService
      .getTerms()
      .then((data) => {
        console.log(data.data);
        const content = data.data.content;
        if (typeof content === 'object' && content !== null) {
          setTermsEn(content.en || '');
          setTermsAr(content.ar || '');
        } else {
          setTermsEn(content || '');
          setTermsAr('');
        }
      })
      .catch((e) => {
        console.log(e);
      });
  };
  const { data, isLoading } = useSWR('terms', fetchTerms);
  const handleClickAction = async () => {
    if (!isEdit) {
      setIsEdit(true);
    } else {
      setLoading(true);
      await termsService
        .updateTerms({ en: termsEn, ar: termsAr })
        .then(() => {
          setLoading(false);
          toast.success('Terms & Conditions updated successfully');
          setIsEdit(false);
        })
        .catch((e) => {
          setLoading(false);

          toast.error(e.response.data.message.en);
        });
    }
  };
  return (
    <div className="flex h-full min-h-[600px] w-full flex-col items-center justify-start gap-6 ">
      <h2 className="border-b border-primary pb-3   ">
        {!isEdit ? 'Terms & Conditions' : 'Edit Terms & Conditions'}
      </h2>
      <div className="w-[60%] space-y-4">
        <div>
          <label className="mb-2 block text-sm font-semibold text-slate-700">English (EN)</label>
          <Textarea
            rows={10}
            className="overflow-y-scroll border-2 border-primary"
            disabled={!isEdit}
            placeholder="Type English terms & conditions here."
            value={termsEn}
            onChange={(e) => setTermsEn(e.target.value)}
          />
        </div>
        <div>
          <label className="mb-2 block text-sm font-semibold text-slate-700">Arabic (AR)</label>
          <Textarea
            rows={10}
            className="overflow-y-scroll border-2 border-primary"
            disabled={!isEdit}
            placeholder="اكتب الشروط والأحكام العربية هنا"
            value={termsAr}
            onChange={(e) => setTermsAr(e.target.value)}
            dir="rtl"
          />
        </div>
      </div>
      <div className="flex w-1/2 items-center justify-center gap-3">
        <Button loading={loading} disabled={loading} onClick={() => handleClickAction()}>
          {isEdit ? 'Save' : 'Edit'}
        </Button>
        {isEdit && (
          <Button onClick={() => setIsEdit(false)} variant="secondary">
            Cancel
          </Button>
        )}
      </div>
    </div>
  );
};

export default Terms;
