import React, { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Textarea } from '@/components/ui/textarea';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { FileUp, AlertCircle, ChevronLeft, ChevronRight } from 'lucide-react';

declare global {
  interface Window {
    mermaid: any;
  }
}

interface Block {
  id: number;
  label: string;
  successors: Block[];
}

interface Function {
  name: string;
  type: string;
  start_line: number;
  end_line: number;
  blocks: Block[];
  simplified_code: string;
}

interface CFGData {
  name: string;
  type: string;
  functions: Function[];
  blocks: Block[];
}

const CFGVisualizer = () => {
  const [leftJsonlData, setLeftJsonlData] = useState<CFGData[]>([]);
  const [rightJsonlData, setRightJsonlData] = useState<CFGData[]>([]);
  const [leftJsonInput, setLeftJsonInput] = useState('');
  const [rightJsonInput, setRightJsonInput] = useState('');
  const [leftError, setLeftError] = useState('');
  const [rightError, setRightError] = useState('');
  const [leftSelectedFunction, setLeftSelectedFunction] = useState('');
  const [rightSelectedFunction, setRightSelectedFunction] = useState('');
  const [currentIndex, setCurrentIndex] = useState(0);

  useEffect(() => {
    const loadMermaid = async () => {
      if (!window.mermaid) {
        const script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js';
        script.async = true;
        script.onload = () => {
          window.mermaid.initialize({
            startOnLoad: true,
            theme: 'default',
            securityLevel: 'loose',
            flowchart: {
              htmlLabels: true,
              curve: 'basis'
            }
          });
        };
        document.body.appendChild(script);
      }
    };
    loadMermaid();
  }, []);

  useEffect(() => {
    if (window.mermaid) {
      window.mermaid.contentLoaded();
    }
  }, [leftJsonlData, rightJsonlData, leftSelectedFunction, rightSelectedFunction, currentIndex]);

  const parseJsonl = (content: string): CFGData[] => {
    return content
      .trim()
      .split('\n')
      .filter(line => line.trim())
      .map(line => JSON.parse(line));
  };

  const handleFileUpload = (side: 'left' | 'right') => (event) => {
    const file = event.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const content = e.target.result as string;
        const jsonlData = parseJsonl(content);
        
        if (side === 'left') {
          setLeftJsonlData(jsonlData);
          setLeftJsonInput(content);
          setLeftError('');
          if (jsonlData.length > 0) {
            const firstData = jsonlData[0];
            const firstFunction = firstData.functions?.[0]?.name || 'root';
            setLeftSelectedFunction(firstFunction);
          }
        } else {
          setRightJsonlData(jsonlData);
          setRightJsonInput(content);
          setRightError('');
          if (jsonlData.length > 0) {
            const firstData = jsonlData[0];
            const firstFunction = firstData.functions?.[0]?.name || 'root';
            setRightSelectedFunction(firstFunction);
          }
        }
        setCurrentIndex(0);
      } catch (err) {
        if (side === 'left') {
          setLeftError('无效的JSONL文件格式');
          setLeftJsonlData([]);
        } else {
          setRightError('无效的JSONL文件格式');
          setRightJsonlData([]);
        }
      }
    };
    reader.readAsText(file);
  };

  const handleInputChange = (side: 'left' | 'right') => (value: string) => {
    if (side === 'left') {
      setLeftJsonInput(value);
    } else {
      setRightJsonInput(value);
    }

    try {
      if (value.trim()) {
        const jsonlData = parseJsonl(value);
        if (side === 'left') {
          setLeftJsonlData(jsonlData);
          setLeftError('');
          if (jsonlData.length > 0) {
            const firstData = jsonlData[0];
            const firstFunction = firstData.functions?.[0]?.name || 'root';
            setLeftSelectedFunction(firstFunction);
          }
        } else {
          setRightJsonlData(jsonlData);
          setRightError('');
          if (jsonlData.length > 0) {
            const firstData = jsonlData[0];
            const firstFunction = firstData.functions?.[0]?.name || 'root';
            setRightSelectedFunction(firstFunction);
          }
        }
        setCurrentIndex(0);
      } else {
        if (side === 'left') {
          setLeftJsonlData([]);
          setLeftError('');
        } else {
          setRightJsonlData([]);
          setRightError('');
        }
      }
    } catch (err) {
      if (side === 'left') {
        setLeftError('无效的JSONL格式');
        setLeftJsonlData([]);
      } else {
        setRightError('无效的JSONL格式');
        setRightJsonlData([]);
      }
    }
  };

  const generateMermaidCode = (data: CFGData | null, selectedFunction: string) => {
    if (!data) return '';

    let blocks: Block[] = [];
    if (selectedFunction === 'root') {
      blocks = data.blocks || [];
    } else {
      const func = data.functions.find(f => f.name === selectedFunction);
      if (!func) return '';
      blocks = func.blocks || [];
    }

    if (blocks.length === 0) return '';

    let mermaidCode = 'graph TB\n';
    const processedNodes = new Set<number>();
    
    const processBlock = (block: Block) => {
      if (processedNodes.has(block.id)) return;
      processedNodes.add(block.id);

      const safeLabel = block.label
        .replace(/"/g, "'")
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .split('\n')
        .join('<br/>');
      
      mermaidCode += `  ${block.id}["${safeLabel}"]\n`;

      if (block.successors) {
        block.successors.forEach(successor => {
          mermaidCode += `  ${block.id} --> ${successor.id}\n`;
          processBlock(successor);
        });
      }
    };

    blocks.forEach(block => processBlock(block));
    return mermaidCode;
  };

  const JsonInput = ({ side }: { side: 'left' | 'right' }) => {
    const data = (side === 'left' ? leftJsonlData : rightJsonlData)[currentIndex];
    const functions = data?.functions || [];

    return (
      <div className="space-y-4">
        <Tabs defaultValue="input">
          <TabsList>
            <TabsTrigger value="input">直接输入</TabsTrigger>
            <TabsTrigger value="upload">文件上传</TabsTrigger>
          </TabsList>

          <TabsContent value="input">
            <Textarea
              placeholder="请输入JSONL数据..."
              value={side === 'left' ? leftJsonInput : rightJsonInput}
              onChange={(e) => handleInputChange(side)(e.target.value)}
              className="min-h-[200px] font-mono"
            />
          </TabsContent>

          <TabsContent value="upload">
            <div className="flex items-center gap-4">
              <input
                type="file"
                accept=".jsonl"
                onChange={handleFileUpload(side)}
                className="hidden"
                id={`json-upload-${side}`}
              />
              <label htmlFor={`json-upload-${side}`}>
                <Button variant="outline" className="cursor-pointer">
                  <FileUp className="mr-2 h-4 w-4" />
                  选择文件
                </Button>
              </label>
            </div>
          </TabsContent>
        </Tabs>

        {(side === 'left' ? leftError : rightError) && (
          <Alert variant="destructive">
            <AlertCircle className="h-4 w-4" />
            <AlertDescription>{side === 'left' ? leftError : rightError}</AlertDescription>
          </Alert>
        )}

        {data && (
          <Select
            value={side === 'left' ? leftSelectedFunction : rightSelectedFunction}
            onValueChange={(value) => {
              if (side === 'left') {
                setLeftSelectedFunction(value);
              } else {
                setRightSelectedFunction(value);
              }
            }}
          >
            <SelectTrigger className="w-full">
              <SelectValue placeholder="选择函数" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="root">根级CFG</SelectItem>
              {functions.map((func) => (
                <SelectItem key={func.name} value={func.name}>
                  {func.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        )}

        {data && (side === 'left' ? leftSelectedFunction : rightSelectedFunction) && (
          <div className="border rounded-lg p-4 bg-white">
            <div className="mermaid">
              {generateMermaidCode(
                data,
                side === 'left' ? leftSelectedFunction : rightSelectedFunction
              )}
            </div>
          </div>
        )}
      </div>
    );
  };

  const maxIndex = Math.max(leftJsonlData.length, rightJsonlData.length) - 1;

  return (
    <div className="p-4 max-w-7xl mx-auto">
      <Card className="p-6">
        <div className="flex justify-between items-center mb-4">
          <h1 className="text-2xl font-bold">CFG可视化对比工具</h1>
          {maxIndex > 0 && (
            <div className="flex items-center gap-4">
              <Button
                variant="outline"
                onClick={() => setCurrentIndex(prev => Math.max(0, prev - 1))}
                disabled={currentIndex === 0}
              >
                <ChevronLeft className="h-4 w-4" />
                上一个
              </Button>
              <span className="text-sm">
                {currentIndex + 1} / {maxIndex + 1}
              </span>
              <Button
                variant="outline"
                onClick={() => setCurrentIndex(prev => Math.min(maxIndex, prev + 1))}
                disabled={currentIndex === maxIndex}
              >
                下一个
                <ChevronRight className="h-4 w-4" />
              </Button>
            </div>
          )}
        </div>
        
        <div className="grid grid-cols-2 gap-4">
          <div>
            <h2 className="text-lg font-semibold mb-2">图 A</h2>
            <JsonInput side="left" />
          </div>
          <div>
            <h2 className="text-lg font-semibold mb-2">图 B</h2>
            <JsonInput side="right" />
          </div>
        </div>
      </Card>
    </div>
  );
};

export default CFGVisualizer;