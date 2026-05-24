// 音乐管理类
// 这个文件用普通 Java 写是因为 Processing 的 pde 预处理器容易误判 Java Sound 代码
import java.io.File;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;
import javax.sound.sampled.FloatControl;

public class AudioManager {
  // 这里只有一首背景音乐
  private final String dataFolderPath;
  private Clip bgmClip;

  public AudioManager(String dataFolderPath) {
    // 构造函数只保存 data 文件夹路径
    this.dataFolderPath = dataFolderPath;
  }

  public void load() {
    // 优先找 bgm wav 然后找 data 文件夹里的第一首音频
    File musicFile = findMusicFile();
    if (musicFile == null) {
      System.out.println("Music file not found in data folder");
      return;
    }

    bgmClip = loadClip(musicFile);
  }

  public void start() {
    // 游戏开始后循环播放这一首背景音乐
    startLoop(bgmClip, 0.76f);
  }

  public void stop() {
    // 游戏结束时停止音乐
    stopClip(bgmClip);
  }

  public void update() {
    setVolume(bgmClip, 0.76f);
  }

  private File findMusicFile() {
    File dataFolder = new File(dataFolderPath);
    if (!dataFolder.exists() || !dataFolder.isDirectory()) {
      return null;
    }

    File preferredWav = new File(dataFolder, "bgm.wav");
    if (preferredWav.exists()) {
      return preferredWav;
    }

    File preferredMp3 = new File(dataFolder, "bgm.mp3");
    if (preferredMp3.exists()) {
      return preferredMp3;
    }

    File[] files = dataFolder.listFiles();
    if (files == null) {
      return null;
    }

    for (int i = 0; i < files.length; i++) {
      String name = files[i].getName().toLowerCase();
      if (name.endsWith(".wav")) {
        return files[i];
      }
    }

    for (int i = 0; i < files.length; i++) {
      String name = files[i].getName().toLowerCase();
      if (name.endsWith(".mp3")) {
        return files[i];
      }
    }

    return null;
  }

  private Clip loadClip(File soundFile) {
    // Java Sound 最稳定的是 wav 如果 mp3 不能读取会安全跳过
    try {
      AudioInputStream stream = AudioSystem.getAudioInputStream(soundFile);
      Clip loadedClip = AudioSystem.getClip();
      loadedClip.open(stream);
      stream.close();
      return loadedClip;
    } catch (Exception e) {
      System.out.println("Could not load music file " + soundFile.getName() + " " + e.getMessage());
      return null;
    }
  }

  private void startLoop(Clip clip, float volume) {
    // 从头开始循环播放
    if (clip == null) {
      return;
    }

    clip.stop();
    clip.setFramePosition(0);
    setVolume(clip, volume);
    clip.loop(Clip.LOOP_CONTINUOUSLY);
  }

  private void stopClip(Clip clip) {
    // 安全停止避免空对象报错
    if (clip == null) {
      return;
    }

    clip.stop();
    clip.setFramePosition(0);
  }

  private void setVolume(Clip clip, float amount) {
    // 把 0 到 1 的音量换算成 Java Sound 使用的分贝
    if (clip == null || !clip.isControlSupported(FloatControl.Type.MASTER_GAIN)) {
      return;
    }

    amount = Math.max(0.0f, Math.min(1.0f, amount));
    FloatControl gain = (FloatControl)clip.getControl(FloatControl.Type.MASTER_GAIN);
    if (amount <= 0.001f) {
      gain.setValue(gain.getMinimum());
      return;
    }

    float minGain = Math.max(gain.getMinimum(), -45.0f);
    float maxGain = Math.min(gain.getMaximum(), 0.0f);
    float db = minGain + (maxGain - minGain) * amount;
    gain.setValue(db);
  }
}
