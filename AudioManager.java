// 音乐管理类。
// 这个文件用普通 Java 写，是因为 Processing 的 .pde 预处理器容易误判 Java Sound 代码。
import java.io.File;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;
import javax.sound.sampled.FloatControl;

public class AudioManager {
  // 两首音乐的路径：普通阶段和暗黑阶段。
  private final String normalPath;
  private final String darkPath;
  private final int fadeFrames;

  // Clip 是 Java 自带的音频播放器对象。
  private Clip normalClip;
  private Clip darkClip;

  public AudioManager(String normalPath, String darkPath, int fadeFrames) {
    // 构造函数只保存路径，真正读取文件在 load()。
    this.normalPath = normalPath;
    this.darkPath = darkPath;
    this.fadeFrames = fadeFrames;
  }

  public void load() {
    // 如果文件不存在，loadClip 会返回 null，游戏不会崩。
    normalClip = loadClip(normalPath, "paper_drift_normal.wav");
    darkClip = loadClip(darkPath, "paper_drift_dark.wav");
  }

  public void start() {
    // 游戏开始时两首都开始循环，暗黑音乐音量为 0，这样切换时不会卡一下。
    startLoop(normalClip, 0.74f);
    startLoop(darkClip, 0.0f);
  }

  public void startDarkLoop() {
    // 保险用：如果暗黑音乐还没跑，就从头开始静音循环。
    if (darkClip != null && !darkClip.isRunning()) {
      startLoop(darkClip, 0.0f);
    }
  }

  public void stop() {
    // 游戏结束时停止两首音乐。
    stopClip(normalClip);
    stopClip(darkClip);
  }

  public void update(int phase, int phaseTwoFrames) {
    // 普通阶段只听 normal，暗黑阶段 normal 淡出、dark 淡入。
    if (phase == 1) {
      setVolume(normalClip, 0.74f);
      setVolume(darkClip, 0.0f);
      return;
    }

    startDarkLoop();
    float fade = Math.max(0.0f, Math.min(1.0f, phaseTwoFrames / (float)fadeFrames));
    setVolume(normalClip, 0.74f * (1.0f - fade));
    setVolume(darkClip, 0.82f * fade);
  }

  private Clip loadClip(String path, String label) {
    // 读取 wav 文件，出错只打印信息，不影响游戏本身。
    try {
      File soundFile = new File(path);
      if (!soundFile.exists()) {
        System.out.println("Music file not found: data/" + label);
        return null;
      }

      AudioInputStream stream = AudioSystem.getAudioInputStream(soundFile);
      Clip loadedClip = AudioSystem.getClip();
      loadedClip.open(stream);
      stream.close();
      return loadedClip;
    } catch (Exception e) {
      System.out.println("Could not load music file " + label + ": " + e.getMessage());
      return null;
    }
  }

  private void startLoop(Clip clip, float volume) {
    // 从头开始循环播放。
    if (clip == null) {
      return;
    }

    clip.stop();
    clip.setFramePosition(0);
    setVolume(clip, volume);
    clip.loop(Clip.LOOP_CONTINUOUSLY);
  }

  private void reset(Clip clip) {
    // 停止并回到开头。
    if (clip == null) {
      return;
    }

    clip.stop();
    clip.setFramePosition(0);
  }

  private void stopClip(Clip clip) {
    // 安全停止，避免 null 报错。
    if (clip == null) {
      return;
    }

    clip.stop();
    clip.setFramePosition(0);
  }

  private void setVolume(Clip clip, float amount) {
    // 把 0~1 的音量换成 Java Sound 用的分贝值。
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
