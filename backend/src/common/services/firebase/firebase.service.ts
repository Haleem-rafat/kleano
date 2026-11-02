import 'dotenv/config';
import { FirebaseApp, FirebaseBucket } from './firebase.config';
import { File } from '@google-cloud/storage';
import { v4 as uuidv4 } from 'uuid';
import { unlink } from 'fs';
import { Injectable } from '@nestjs/common';
import { MethodNotAllowedResponse } from '../../errors/MethodNotAllowedResponse';

@Injectable()
export class FirebaseService {
  constructor() {
    /* TODO document why this constructor is empty */
  }

  async uploadImage(image: Express.Multer.File, prefix = 'uploadedImage') {
    const fileId = uuidv4();
    const metadata = {
      // used to create a download token
      metadata: { firebaseStorageDownloadTokens: fileId },
      contentType: 'image/jpeg',
      cacheControl: 'public, max-age=31536000',
    };
    const filePath = `${prefix}-${fileId}`;

    let data: any;
    try {
      data = await FirebaseBucket.upload(`uploads/${image.filename}`, {
        // Support for HTTP requests made with `Accept-Encoding: gzip`
        gzip: true,
        metadata: metadata,
        destination: filePath,
      });
    } catch {
      throw new MethodNotAllowedResponse({
        ar: 'خطأ داخلى فى رفع الصور، برجاء إعادة المحاولة',
        en: 'Error uploading images to the cloud, please try again.',
      });
    }

    // eslint-disable-next-line @typescript-eslint/no-empty-function
    unlink(`${process.cwd()}/uploads/${image.filename}`, () => {});

    return {
      fileName: image.originalname,
      fileLink: this.getDownloadLink(data[0], fileId),
      size: data[0].metadata.size,
      fileId: fileId,
      filePath: filePath,
    };
  }

  async deleteFileFromStorage(filePath: string) {
    try {
      await FirebaseBucket.file(filePath).delete();
    } catch (error) {
      console.error(error);
    }
  }

  getDownloadLink(file: File, downloadToken: string) {
    return (
      'https://firebasestorage.googleapis.com/v0/b/' +
      FirebaseBucket.name +
      '/o/' +
      encodeURIComponent(file.name) +
      '?alt=media&token=' +
      downloadToken
    );
  }

  async deleteUser(uid: string) {
    await FirebaseApp.auth().deleteUser(uid);
  }

  async uploadIcon(fileName: string, prefix = 'uploadedIcon') {
    const fileId = uuidv4();
    const metadata = {
      // used to create a download token
      metadata: { firebaseStorageDownloadTokens: fileId },
      contentType: 'image/jpeg',
      cacheControl: 'public, max-age=31536000',
    };
    const filePath = `${prefix}-${fileId}`;

    let data: any;
    try {
      data = await FirebaseBucket.upload(`icons/${fileName}`, {
        // Support for HTTP requests made with `Accept-Encoding: gzip`
        gzip: true,
        metadata: metadata,
        destination: filePath,
      });
    } catch {
      throw new MethodNotAllowedResponse({
        ar: 'خطأ داخلى فى رفع الصور، برجاء إعادة المحاولة',
        en: 'Error uploading images to the cloud, please try again.',
      });
    }

    // eslint-disable-next-line @typescript-eslint/no-empty-function
    unlink(`${process.cwd()}/icons/${fileName}`, () => {});

    return {
      fileLink: this.getDownloadLink(data[0], fileId),
      filePath: filePath,
    };
  }
}
