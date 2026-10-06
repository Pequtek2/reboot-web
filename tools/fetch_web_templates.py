import urllib.request,io,zipfile,pathlib
url='https://github.com/godotengine/godot-builds/releases/download/4.5.1-stable/Godot_v4.5.1-stable_export_templates.tpz'
r=urllib.request.urlopen(urllib.request.Request(url,method='HEAD')); size=int(r.headers['Content-Length']);url=r.url
class Remote(io.RawIOBase):
 def __init__(self):self.pos=0
 def seekable(self):return True
 def seek(self,o,w=0):self.pos=o if w==0 else self.pos+o if w==1 else size+o;return self.pos
 def tell(self):return self.pos
 def read(self,n=-1):
  n=size-self.pos if n<0 else min(n,size-self.pos)
  if n<=0:return b''
  req=urllib.request.Request(url,headers={'Range':f'bytes={self.pos}-{self.pos+n-1}'})
  with urllib.request.urlopen(req,timeout=120) as response:
   if response.status!=206:raise RuntimeError('Range unsupported')
   data=response.read()
  self.pos+=len(data);return data
with zipfile.ZipFile(Remote()) as z:
 for name in ['templates/web_nothreads_release.zip','templates/web_nothreads_debug.zip']:
  data=z.read(name)
  with zipfile.ZipFile(io.BytesIO(data)) as inner: assert inner.testzip() is None
  target=pathlib.Path('.tools')/pathlib.Path(name).name;target.write_bytes(data);print(target,len(data),flush=True)
