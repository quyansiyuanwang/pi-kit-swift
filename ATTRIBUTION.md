# Attribution

PiKit is a **composition layer**, not a port. It is an independent Swift package
that assembles two existing Swift ports into an application-ready runtime:

- [`PiAI`](https://github.com/quyansiyuanwang/pi-ai-swift) — provider contracts,
  model/message/tool types, JSON `JSONValue` / `JSONSchema`.
- [`PiAgentCore`](https://github.com/quyansiyuanwang/pi-agent-swift) — the
  `Agent` actor and its tool loop.

Both are native Swift ports of [`@earendil-works/pi`](https://github.com/earendil-works/pi)
(upstream version **1.2.0**), which is distributed under the MIT License:

- Upstream source: <https://github.com/earendil-works/pi>
- Upstream version ported: **1.2.0**
- Upstream license: **MIT**
- Upstream copyright: **Copyright (c) 2025 Mario Zechner**

PiKit contains **no TypeScript sources** and no copied upstream implementation.
It only adds glue: configuration, provider parameter injection, text helpers and
a closure-backed tool. Where the composition layer makes a design decision, it
is documented in [`docs/PORTING.md`](docs/PORTING.md).

The upstream MIT license text is reproduced below and its copyright notice is
retained in this repository's [`LICENSE`](LICENSE).

## Upstream license

```
MIT License

Copyright (c) 2025 Mario Zechner

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Dependency licenses

| Package | License | Copyright |
| --- | --- | --- |
| `PiAI` | MIT | Copyright (c) 2025 PiAI contributors; portions Copyright (c) 2025 Mario Zechner |
| `PiAgentCore` | MIT | Copyright (c) 2025 PiAgentCore contributors; portions Copyright (c) 2025 Mario Zechner |
