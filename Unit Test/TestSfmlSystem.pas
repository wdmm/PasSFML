unit TestSfmlSystem;

interface

uses
  TestFramework, SfmlSystem;

type
  TestTSfmlTime = class(TTestCase)
  published
    procedure TestTimeZero;

    procedure TestTimeAsSeconds;
    procedure TestTimeAsMilliseconds;
    procedure TestTimeAsMicroseconds;

    procedure TestSeconds;
    procedure TestMilliseconds;
    procedure TestMicroseconds;
  end;

  TestTSfmlClock = class(TTestCase)
  strict private
    FSfmlClock: TSfmlClock;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCopy;
    procedure TestElapsedTime;
    procedure TestRestart;
  end;

  TestTSfmlThread = class(TTestCase)
  strict private
    FSfmlThread: TSfmlThread;
  public
    Signal: Boolean;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestLaunchWait;
    procedure TestLaunchTerminate;
  end;

implementation

{ TestTSfmlTime }

procedure TestTSfmlTime.TestMicroseconds;
var
  Time: TSfmlTime;
  Microseconds: Int64;
begin
  Microseconds := 1234;
  Time := SfmlMicroseconds(Microseconds);
  CheckEquals(Microseconds, Time.MicroSeconds);
end;

procedure TestTSfmlTime.TestMilliseconds;
var
  Time: TSfmlTime;
  Milleseconds: LongInt;
begin
  Milleseconds := 1234;
  Time := SfmlMilliseconds(Milleseconds);
  CheckEquals(1000 * Milleseconds, Time.MicroSeconds);
end;

procedure TestTSfmlTime.TestSeconds;
var
  Time: TSfmlTime;
  Seconds: Single;
begin
  Seconds := 1;
  Time := SfmlSeconds(Seconds);
  CheckEquals(Round(Seconds * 1000000), Time.MicroSeconds);
end;

procedure TestTSfmlTime.TestTimeAsMicroseconds;
var
  Time: TSfmlTime;
  Microseconds: Int64;
begin
  Time.MicroSeconds := 1234;
  Microseconds := SfmlTimeAsMicroseconds(Time);
  CheckEquals(Time.MicroSeconds, Microseconds);
end;

procedure TestTSfmlTime.TestTimeAsMilliseconds;
var
  Time: TSfmlTime;
  Milliseconds: LongInt;
begin
  Time.MicroSeconds := 1234000;
  Milliseconds := SfmlTimeAsMilliseconds(Time);
  CheckEquals(Time.MicroSeconds div 1000, Milliseconds);
end;

procedure TestTSfmlTime.TestTimeAsSeconds;
var
  Time: TSfmlTime;
  Seconds: Single;
begin
  Time.MicroSeconds := 1000000;
  Seconds := SfmlTimeAsSeconds(Time);
  CheckEquals(Time.MicroSeconds / 1000000, Seconds);
end;

procedure TestTSfmlTime.TestTimeZero;
var
  ReturnValue: TSfmlTime;
begin
  ReturnValue := SfmlTimeZero;
  CheckEquals(ReturnValue.MicroSeconds, 0);
end;


{ TestTSfmlClock }

procedure TestTSfmlClock.SetUp;
begin
  FSfmlClock := TSfmlClock.Create;
end;

procedure TestTSfmlClock.TearDown;
begin
  FSfmlClock.Free;
  FSfmlClock := nil;
end;

procedure TestTSfmlClock.TestCopy;
var
  CopiedClock: TSfmlClock;
begin
  CopiedClock := FSfmlClock.Copy;
  Check(CopiedClock.ElapsedTime.MicroSeconds >= FSfmlClock.ElapsedTime.MicroSeconds);
end;

procedure TestTSfmlClock.TestElapsedTime;
var
  TimeStamp: array [0..1] of TSfmlTime;
begin
  TimeStamp[0] := FSfmlClock.ElapsedTime;
  SfmlSleep(SfmlSeconds(1));
  TimeStamp[1] := FSfmlClock.ElapsedTime;

  Check(TimeStamp[1].MicroSeconds > TimeStamp[0].MicroSeconds);
end;

procedure TestTSfmlClock.TestRestart;
var
  TimeStamp: array [0..1] of TSfmlTime;
begin
  TimeStamp[0] := FSfmlClock.Restart;
  TimeStamp[1] := FSfmlClock.Restart;

  Check(TimeStamp[1].MicroSeconds < TimeStamp[1].MicroSeconds);
end;


{ TestTSfmlThread }

procedure TestFunction(UserData: Pointer); cdecl;
begin
  // sleep one second
//  SfmlSleep(SfmlSeconds(1));

  // set signal
  Assert(TObject(UserData) is TestTSfmlThread);
  TestTSfmlThread(UserData).Signal := True;
end;

procedure TestTSfmlThread.SetUp;
begin
  FSfmlThread := TSfmlThread.Create(@TestFunction, Self);
end;

procedure TestTSfmlThread.TearDown;
begin
  FSfmlThread.Free;
  FSfmlThread := nil;
end;

procedure TestTSfmlThread.TestLaunchWait;
begin
  Signal := False;
  FSfmlThread.Launch;
  FSfmlThread.Wait;
  CheckTrue(Signal);
end;

procedure TestTSfmlThread.TestLaunchTerminate;
begin
  Signal := False;
  FSfmlThread.Launch;
  FSfmlThread.Terminate;
  CheckFalse(Signal, 'Thread terminated too late');
end;

initialization
  RegisterTest(TestTSfmlTime.Suite);
  RegisterTest(TestTSfmlClock.Suite);
  RegisterTest(TestTSfmlThread.Suite);
end.
