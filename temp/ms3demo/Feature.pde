import java.nio.*;
public class Featrue
{
  float[] data;
  Featrue(float[] data)
  {
    this.data = data;
  }
  byte[] get_bytes()
  {
    ByteBuffer byteBuffer = ByteBuffer.allocate(257);
    byteBuffer.order(ByteOrder.LITTLE_ENDIAN);
    byteBuffer.put((byte)0x0D);
    for (int i = 0; i != 64; i++)
    {
      byteBuffer.putFloat(1 + i * 4, this.data[i]);
    }
    return byteBuffer.array();
  }
  void send(Serial p){
    p.write(this.get_bytes());
  }
}