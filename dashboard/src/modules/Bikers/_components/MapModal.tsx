import bikersService from '@services/bikers.service';
import { APIProvider, Map, Marker, MapMouseEvent } from '@vis.gl/react-google-maps';
import { Dispatch, SetStateAction } from 'react';
import { useTranslation } from 'react-i18next';
import { IoMdCloseCircle } from 'react-icons/io';
import { toast } from 'react-toastify';
interface MapModalProps {
  isMapOpen: boolean;
  setIsMapOpen: Dispatch<SetStateAction<boolean>>;
  selectedPoints: { lat: number; lng: number }[];
  setSelectedPoints: Dispatch<SetStateAction<{ lat: number; lng: number }[]>>;
  selectedAreas: string[]; // Store only area IDs
  setSelectedAreas: Dispatch<SetStateAction<string[]>>;
}
export default function MapModal({
  isMapOpen,
  setIsMapOpen,
  selectedPoints,
  setSelectedPoints,
  selectedAreas,
  setSelectedAreas,
}: MapModalProps) {
  const googleMapsApiKey = import.meta.env.VITE_GOOGLE_MAPS_API_KEY;
  const { t, i18n } = useTranslation();
  const lang = i18n.language as 'en' | 'ar';
  const handleMapClick = (event: MapMouseEvent) => {
    if (!event.detail.latLng) return; // Ensure latLng exists
    const { lat, lng } = event.detail.latLng; // Extract lat & lng from latLng object
    bikersService
      .getAreaId(lat, lng)
      .then((response) => {
        if (response && response.success && response.data) {
          const areaId = response.data._id; // Extract correct _id
          toast.success('Area Marked successfully');
          setSelectedAreas((prevAreas) => {
            if (prevAreas.includes(areaId)) return prevAreas; // Avoid duplicates
            return [...prevAreas, areaId];
          });
          setSelectedPoints((prevPoints) => {
            const exists = prevPoints.some((point) => point.lat === lat && point.lng === lng);
            if (exists) return prevPoints; // Avoid duplicates
            return [...prevPoints, { lat, lng }];
          });
        }
      })
      .catch(({ response }) => {
        const messages = response?.data?.message;
        const errList = Array.isArray(messages)
          ? messages.join(', ')
          : messages?.[lang] || t('Area not covered.');
        toast.error(errList);
      });
  };
  const handleDeleteMarker = (pointToDelete: { lat: number; lng: number }) => {
    setSelectedPoints((prev) =>
      prev.filter((point) => point.lat !== pointToDelete.lat || point.lng !== pointToDelete.lng)
    );
    bikersService.getAreaId(pointToDelete.lat, pointToDelete.lng).then((response) => {
      if (response?.success && response.data?._id) {
        const areaIdToRemove = response.data._id;
        setSelectedAreas((prev) => prev.filter((id) => id !== areaIdToRemove));
      }
    });
  };

  return (
    isMapOpen && (
      <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50">
        <div className="relative h-[70vh] w-11/12 rounded-lg bg-white p-4">
          <button onClick={() => setIsMapOpen(false)} className="absolute right-1 top-1 text-xl">
            <IoMdCloseCircle className="h-6 w-6" />
          </button>
          <APIProvider apiKey={googleMapsApiKey}>
            <div className="relative h-full w-full">
              <Map
                className="h-full w-[99%]"
                defaultCenter={{ lat: 24.7136, lng: 46.6753 }}
                defaultZoom={10}
                onClick={handleMapClick} // Updated to use MapMouseEvent correctly
              >
                {selectedPoints.map((point, index) => (
                  <Marker
                    key={index}
                    position={point}
                    icon={{
                      url: 'https://res.cloudinary.com/dz33uga3j/image/upload/v1745761131/Screenshot_2025-04-27_163557_yxw4ey.png',
                      scaledSize: {
                        width: 20,
                        height: 20,
                        equals: function (other: google.maps.Size | null): boolean {
                          throw new Error('Function not implemented.');
                        },
                      },
                    }}
                    onClick={() => handleDeleteMarker(point)}
                  />
                ))}
              </Map>
            </div>
          </APIProvider>
        </div>
      </div>
    )
  );
}
