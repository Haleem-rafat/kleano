import { Location } from '@servicesTypes/order.types';
import { Dialog, DialogContent } from '@shadecn/components/ui/dialog';
import LeafletMap from '@shadecn/components/ui/leaflet-map';

interface LocationMapDialogProps {
  isOpen: boolean;
  onClose: () => void;
  location: Location;
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
  const hasLocation = location.latitude && location.longitude;

  if (!hasLocation) {
    return null;
  }

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="min-h-[90vh] sm:max-w-6xl">
        <div className="space-y-4">
          <div className="flex items-center gap-2 text-sm text-gray-600">
            <div>
              <strong>Street Name:</strong> {streetName}
            </div>

            <div>
              <strong>City Name:</strong> {cityName}
            </div>
          </div>

          <LeafletMap
            latitude={location.latitude}
            longitude={location.longitude}
            zoom={15}
            height="80vh"
            className="w-full rounded-lg"
            markerTitle={`${streetName} - ${cityName}`}
            popupContent={
              <div className="text-sm">
                <div className="font-medium">Street Name: {streetName}</div>
                <div className="text-gray-600">City: {cityName}</div>
                <div className="mt-1 text-xs text-gray-500">
                  Coordinates: {location.latitude}, {location.longitude}
                </div>
              </div>
            }
          />
        </div>
      </DialogContent>
    </Dialog>
  );
};

export default LocationMapDialog;
