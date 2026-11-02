import { lazy, Suspense } from 'react';
import { useTranslation } from 'react-i18next';
import { Location } from '@servicesTypes/order.types';
import { Dialog, DialogContent, DialogTitle } from '@shadecn/components/ui/dialog';

// Leaflet (~150 kB) loads only when a map is opened, not with the orders table.
const LeafletMap = lazy(() => import('@shadecn/components/ui/leaflet-map'));

interface LocationMapDialogProps {
  isOpen: boolean;
  onClose: () => void;
  location?: Location;
  cityName: string;
  streetName: string;
}

const LocationMapDialog = ({
  isOpen,
  onClose,
  location,
  cityName,
  streetName,
}: LocationMapDialogProps) => {
  const { t } = useTranslation();
  const hasLocation = location?.latitude && location?.longitude;

  if (!hasLocation) {
    return null;
  }

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="min-h-[90vh] sm:max-w-6xl">
        <div className="space-y-4">
          <DialogTitle className="text-base font-semibold text-foreground">
            {t('location')}
          </DialogTitle>
          <div className="flex flex-wrap items-center gap-4 text-sm text-muted-foreground">
            <div>
              <strong className="text-foreground">{t('streetName')}:</strong> {streetName}
            </div>
            <div>
              <strong className="text-foreground">{t('cityName')}:</strong> {cityName}
            </div>
          </div>

          {isOpen && (
            <Suspense
              fallback={
                <div className="h-[80vh] w-full animate-pulse rounded-lg bg-muted" aria-busy />
              }>
              <LeafletMap
                latitude={location.latitude}
                longitude={location.longitude}
                zoom={15}
                height="80vh"
                className="w-full rounded-lg"
                markerTitle={`${streetName} - ${cityName}`}
                popupContent={
                  <div className="text-sm">
                    <div className="font-medium">
                      {t('streetName')}: {streetName}
                    </div>
                    <div className="text-muted-foreground">
                      {t('cityName')}: {cityName}
                    </div>
                    <div className="mt-1 text-xs text-muted-foreground">
                      {location.latitude}, {location.longitude}
                    </div>
                  </div>
                }
              />
            </Suspense>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
};

export default LocationMapDialog;
