# MapReduce

## Задание

Процесс-исполнитель задачек

### API

1. Создавать исполнителя и прилинковывать его к вызывающему процессу `create() -> worker`  
  Тут должен с помощью `spawn_link` создаться процесс.  
  В этом процессе должна быть рекурсивная функция, внутри которой вызывается `receive`, в котором обрабатываются получаемые сообщения
  Что-то типа:
```Elixir
  defp loop(state) do
    receive do
      message ->
        state = handle_message(message, state)
      loop(state)
    end
  end
```

2. Запускать задачку `execute(worker, job) -> job_id`  
  Сама `job` это замыкание (то есть что-то типа `job = fn -> 1 + 1 end`)  
  То есть нужно написать функцию execute, которая будет посылать сообщение в котором будет сама работа и `pid` на который прислать результат. Ещё нужно повесить `Process.monitor`, чтобы понять что сообщение дошло.  
  И ещё нужно получить сообщение в `loop`, вернуть `job_id` и начать исполнять задачку.  
  А после исполнения записать результат в мапу с результатами по `job_id`

3. Получать результат задачки по `job_id`: `get_result(worker, job_id) -> result`  
  Примерно такая же тема как и выше, но с другой бизнес логикой.  
  Она должна либо получить результат сразу, либо подождать пока такой `job_id` исполнится

4. ⭐ Функция, которая позволяет запустить несколько задачек и редьюснуть их ассоциативной функцией.  
  `reduce(worker, jobs, associative_func)`
  Не обязательно её сделать сейчас, но желательно  
  То есть, нужно исполнять `jobs`, и потом к результатам применять associative_func  
  То есть типа  
  `reduce(worker, [job1, job2, job3], fn left, right -> left + right end) должно вернуть что-то типа job1.() + job2.() + job3.()`

### Требования

* mix new map_reduce
* Сделать это через `spawn` и т.н. `receive loop`
* тесты в ExUnit по принципу AAA (Arrange, Action, Assert)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `map_reduce` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:map_reduce, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/map_reduce>.

