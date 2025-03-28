import fs from '@ohos.file.fs';
import { media } from '@kit.MediaKit';
import { image } from '@kit.ImageKit';

class FsUtil{

  /**
   * 获取视频文件的首帧
   * @param originalPath
   * @param thumbnailPath
   * @param thumbnailSize
   * @param thumbnailOptions
   * @returns
   */
  async getThumbnail(originalPath:string, thumbnailPath: string, thumbnailSize?: media.PixelMapParams, thumbnailOptions?: image.PackingOption): Promise<string> {
    let avImageGenerator: media.AVImageGenerator;
    let queryOption = media.AVImageQueryOptions.AV_IMAGE_QUERY_CLOSEST_SYNC
    let param: media.PixelMapParams = thumbnailSize ?? {width: -1, height: -1};
    avImageGenerator  = await media.createAVImageGenerator()
    const fileNetwork = fs.openSync(originalPath, fs.OpenMode.READ_ONLY);
    const avFileDescriptor:media.AVFileDescriptor = { fd: fileNetwork.fd };
    avImageGenerator.fdSrc = avFileDescriptor;
    const  pixelMap = await avImageGenerator.fetchFrameByTime(0, queryOption, param)

    // 创建图像编码ImagePacker对象
    const imagePackerApi = image.createImagePacker();
    // 设置编码输出流和编码参数。format为图像的编码格式；quality为图像质量，范围从0-100，100为最佳质量
    const options: image.PackingOption = thumbnailOptions ?? { format: "image/jpeg", quality: 100 };

    const file: fs.File = await fs.open(thumbnailPath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    // 使用packing打包获取图片的ArrayBuffer
    const data: ArrayBuffer = await imagePackerApi.packing(pixelMap, options);
    // 将图片的ArrayBuffer数据写入文件
    fs.writeSync(file.fd, data);
    fs.closeSync(file);
    return thumbnailPath
  }

  async saveFile(context: Context, pixelMap: PixelMap): Promise<string> {
    // 创建图像编码ImagePacker对象
    const imagePackerApi = image.createImagePacker();
    // 设置编码输出流和编码参数。format为图像的编码格式；quality为图像质量，范围从0-100，100为最佳质量
    const options: image.PackingOption = { format: "image/jpeg", quality: 100 };
    // 图片写入的沙箱路径
    let currentTimeMillis: number = new Date().getTime();

    const filePath: string = `${context.filesDir}/${currentTimeMillis}.jpg`;
    const file: fs.File = await fs.open(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    // 使用packing打包获取图片的ArrayBuffer
    const data: ArrayBuffer = await imagePackerApi.packing(pixelMap, options);
    // 将图片的ArrayBuffer数据写入文件
    fs.writeSync(file.fd, data);
    fs.closeSync(file);
    return filePath;
  }
}

export const fsUtilStore = new FsUtil()


