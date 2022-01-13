import 'dart:async';

/**
 * Fun facts about Future:
 *
 *    1.The function that you pass into Future’s then() method executes
 *    immediately when the Future completes. (The function isn’t enqueued, it’s just called.)
 *
 *    2.If a Future is already complete before then() is invoked on it,
 *    then a task is added to the microtask queue, and that task executes the function passed into then().
 *
 *    3.The Future() and Future.delayed() constructors don’t complete immediately;
 *    they add an item to the event queue.
 *
 *    4.The Future.value() constructor completes in a microtask, similar to #2.
 *
 *    5.The Future.sync() constructor executes its function argument immediately
 *    and (unless that function returns a Future) completes in a microtask, similar to #2.
 */

/**
 * summary:
 * A Dart app’s event loop executes tasks from two queues: the event queue and the microtask queue.
 *   The event queue has entries from both Dart (futures, timers, isolate messages, and so on) and the system (user actions, I/O, and so on).
 *   Currently, the microtask queue has entries only from Dart, but we expect it to be merged with the browser microtask queue.
 *   The event loop empties the microtask queue before dequeuing and handling the next item on the event queue.
 *   Once both queues are empty, the app has completed its work and (depending on its embedder) can exit.
 *   The main() function and all items from the microtask and event queues run on the Dart app’s main isolate.
 *
 *   When you schedule a task, follow these rules:
 *   If possible, put it on the event queue (using new Future() or new Future.delayed()).
 *   Use Future’s then() or whenComplete() method to specify task order.
 *   To avoid starving the event loop, keep the microtask queue as short as possible.
 *   To keep your app responsive, avoid compute-intensive tasks on either event loop.
 *   To perform compute-intensive tasks, create additional isolates or workers.
 */

void main() {
  // newFuture();
  taskTest2();
}

void newFuture() {
  Future(() => 21).then((value) {
    print("type: ${value.runtimeType}");
    return 32;
  }).then(
    (value) {
      print("type: ${value.runtimeType}");
    },
  );
}

void futureMicroTask() {
  Future.microtask(() => {});
}

void futureDelay() {
  //delay时间完成后添加到 event queue
  Future.delayed(Duration(milliseconds: 300), () {});
}

void futureValue() {
  Future.value(1);
}

void taskTest1() {
  print('main #1 of 2');
  scheduleMicrotask(() => print('microtask #1 of 2'));

  Future.delayed(Duration(seconds: 1), () => print('future #1 (delayed)'));
  Future(() => print('future #2 of 3'));
  Future(() => print('future #3 of 3'));

  scheduleMicrotask(() => print('microtask #2 of 2'));

  print('main #2 of 2');

  // main #1 of 2
  // main #2 of 2
  // microtask #1 of 2
  // microtask #2 of 2
  // future #2 of 3
  // future #3 of 3
  // future #1 (delayed)
}

void taskTest2(){
  print('main #1 of 2');
  scheduleMicrotask(() => print('microtask #1 of 3'));

  Future.delayed(Duration(seconds:1),
          () => print('future #1 (delayed)'));

  Future(() => print('future #2 of 4'))
      .then((_) => print('future #2a'))
      .then((_) {
    print('future #2b');
    scheduleMicrotask(() => print('microtask #0 (from future #2b)'));
  })
      .then((_) => print('future #2c'));

  scheduleMicrotask(() => print('microtask #2 of 3'));

  Future(() => print('future #3 of 4'))
      .then((_) => Future(
          () => print('future #3a (a new future)')))
      .then((_) => print('future #3b'));

  Future(() => print('future #4 of 4'));
  scheduleMicrotask(() => print('microtask #3 of 3'));
  print('main #2 of 2');

  //main #1 of 2
  //main #2 of 2
  //microtask #1 of 3
  //microtask #2 of 3
  //microtask #3 of 3
  //future #2 of 4
  //'future #2a'
  //'future #2b'
  //'future #2c'
  //microtask #0 (from future #2b)
  //future #3 of 4
  //future #4 of 4
  //future #3a (a new future)
  //'future #3b'
  //'future #1 (delayed)'
}
